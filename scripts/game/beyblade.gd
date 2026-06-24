extends RigidBody2D

# --- CORE STATS ---
@export var max_health: float = 100.0
var current_health: float

@export var max_stamina: float = 100.0
var current_stamina: float

# --- PLAYER ONLY STATS ---
@export var max_charge: float = 100.0
var current_charge: float
@export var charge_regen_rate: float = 10.0 # Gains 10% charge per second passively
@export var charge_per_hit: float = 20.0

# --- STAMINA / BOOST TUNING ---
@export var stamina_regen_rate: float = 25.0  # Recovers fast when not boosting
@export var player_boost_cost: float = 50.0   # Lasts exactly 2 seconds on a full tank

# --- PHYSICS TUNING ---
@export var constant_spin_speed: float = 60.0
@export var stadium_slope_force: float = 400.0

# --- PLAYER TUNING ---
@export var player_control_force: float = 700.0
@export var max_player_speed: float = 600.0

# --- AI TUNING ---
@export var enemy_center_pull_force: float = 600.0
@export var enemy_player_track_force: float = 600.0

@export var boost_multiplier: float = 2.0
var damage_cooldown_timer: float = 0.0
@export var damage_cooldown_duration: float = 0.6

var center_node: Marker2D
@onready var sprite: Sprite2D = $Sprite2D

signal health_changed(role, damage, current_health, max_health)

func _ready() -> void:
	current_health = max_health
	current_stamina = max_stamina
	current_charge = 0.0 # Special power starts at 0% and builds up!
	
	angular_velocity = constant_spin_speed * (1 if randf() > 0.5 else -1)
	angular_damp = 0.0
	center_node = get_parent().get_node_or_null("Stadium/CenterPoint")

func _physics_process(delta: float) -> void:
	# Invincibility frames
	if damage_cooldown_timer > 0:
		damage_cooldown_timer -= delta

	angular_velocity = constant_spin_speed * sign(angular_velocity)
	sprite.rotate(angular_velocity * delta)
	
	# Base Gravity
	if center_node:
		var dir_to_center = (center_node.global_position - global_position).normalized()
		var distance = global_position.distance_to(center_node.global_position)
		apply_central_force(dir_to_center * stadium_slope_force * (distance * 0.01))

	# Roles
	if is_in_group("enemies"):
		# AI LOGIC
		var center_force_vector = Vector2.ZERO
		if center_node:
			var dir_to_center = (center_node.global_position - global_position).normalized()
			center_force_vector = dir_to_center * enemy_center_pull_force
			
		# Move toward the player's position
		var player_force_vector = Vector2.ZERO
		
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var player = players[0]
			if is_instance_valid(player):
				var dir_to_player = (player.global_position - global_position).normalized()
				var distance_to_player = global_position.distance_to(player.global_position)
				
				# --- DYNAMIC TRACKING ---
				var proximity_factor = clamp(distance_to_player / 300.0, 0.1, 1.0)
				var scaled_track_force = enemy_player_track_force * proximity_factor
				
				player_force_vector = dir_to_player * scaled_track_force
			
		apply_central_force(center_force_vector + player_force_vector)
		
		# --- ENEMY TOP SPEED CAP ---
		if linear_velocity.length() > max_player_speed:
			linear_velocity = linear_velocity.normalized() * max_player_speed
	else:
		# --- PLAYER CONTROL LOGIC ---
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		if not Input.is_action_pressed("boost") or current_stamina <= 0:
			current_stamina = min(current_stamina + stamina_regen_rate * delta, max_stamina)
		
		# Movement and Spacebar Boost
		if input_dir != Vector2.ZERO or Input.is_action_pressed("boost"):
			var current_force = player_control_force
			
			if Input.is_action_pressed("boost") and current_stamina > 0:
				current_force *= boost_multiplier
				current_stamina = max(current_stamina - player_boost_cost * delta, 0.0)
			
			if input_dir != Vector2.ZERO:
				apply_central_force(input_dir * current_force)
		
		# Top Speed Cap
		if linear_velocity.length() > max_player_speed:
			linear_velocity = linear_velocity.normalized() * max_player_speed

func take_damage(amount: float) -> void:
	current_health = max(current_health - amount, 0.0)
	
	# Console
	var role = "Enemy" if is_in_group("enemies") else "Player"
	print(role, " took ", int(amount), " damage! Remaining HP: ", current_health)
	
	health_changed.emit(role, amount, current_health, max_health)
	
	if current_health <= 0.0:
		die()
		health_changed.emit(role, amount, 0.0, max_health)


func die() -> void:
	var role = "Enemy" if is_in_group("enemies") else "Player"
	print(role, " HAS BURST OUT! MATCH OVER.")
	
	# TODO: Play an explosion sound effect or spawn particle debris here later!
	
	# Safely delete the Beyblade from the active stadium arena
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("beys") and body != self:
		
		# --- KNOCKBACK ---
		var relative_velocity = linear_velocity - body.linear_velocity
		var total_impact_speed = relative_velocity.length()
		
		var push_dir = (global_position - body.global_position).normalized()
		var dynamic_knockback = 250.0 + (total_impact_speed * 0.4)
		apply_central_impulse(push_dir * dynamic_knockback)
		
		# --- DAMAGE SYSTEM ---
		if damage_cooldown_timer <= 0.0:
			var opponent_speed = body.linear_velocity.length()
			var damage_i_take = clamp(opponent_speed * 0.015, 1.5, 12.0)
			
			# Apply damage and start the I-frame cooldown
			take_damage(damage_i_take)
			damage_cooldown_timer = damage_cooldown_duration
			
			# --- PLAYER SPECIAL CHARGE ---
			if not is_in_group("enemies"):
				current_charge = min(current_charge + charge_per_hit, max_charge)
				
				var my_current_speed = linear_velocity.length()
				print("⚔️ CLASH! Your Speed: ", int(my_current_speed), " (Deals: ", String.num(my_current_speed * 0.015, 1), ") | Enemy Speed: ", int(opponent_speed), " (You took: ", String.num(damage_i_take, 1), " HP)")
