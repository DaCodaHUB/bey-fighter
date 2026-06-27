extends RigidBody2D

# --- CORE STATS ---
@export var max_health: float = 100.0
var current_health: float

@export var max_stamina: float = 100.0
var current_stamina: float
var is_overheated: bool = false

# --- TUNING ---
@export var stamina_regen_rate: float = 25.0
@export var player_boost_cost: float = 100.0
@export var constant_spin_speed: float = 60.0
@export var stadium_slope_force: float = 400.0

# --- PLAYER TUNING ---
@export var player_control_force: float = 900.0
@export var max_player_speed: float = 600.0
@export var boost_multiplier: float = 2.0
@export var visual_boost_multiplier: float = 5.0

# --- AI TUNING ---
@export var enemy_center_pull_force: float = 600.0
@export var enemy_player_track_force: float = 600.0

var damage_cooldown_timer: float = 0.0
@export var damage_cooldown_duration: float = 0.6

var center_node: Marker2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	current_health = max_health
	current_stamina = max_stamina
	
	angular_velocity = constant_spin_speed * (1 if randf() > 0.5 else -1)
	angular_damp = 0.0
	
	var centers = get_tree().get_nodes_in_group("center")
	if centers.size() > 0:
		center_node = centers[0] as Marker2D
	else:
		push_warning("⚠️ Warning: No node found in 'center' group! Stadium gravity disabled.")

func _physics_process(delta: float) -> void:
	# Invincibility frames
	if damage_cooldown_timer > 0:
		damage_cooldown_timer -= delta

	var active_spin_speed = constant_spin_speed
	if not is_in_group("enemies"):
		var has_boost_input = Input.is_action_pressed("boost")
		if has_boost_input and current_stamina > 0.0 and not is_overheated:
			active_spin_speed *= visual_boost_multiplier 

	angular_velocity = active_spin_speed * sign(angular_velocity)
	sprite.rotate(angular_velocity * delta)

# --- INTEGRATED RIGIDBODY PHYSICS SYSTEM ---
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if state.angular_velocity == 0.0:
		state.angular_velocity = constant_spin_speed * (1 if randf() > 0.5 else -1)
		state.angular_damp = 0.0

	# Gravity Calculation
	var gravity_velocity_pull = Vector2.ZERO
	if center_node:
		var dir_to_center = (center_node.global_position - global_position).normalized()
		var distance = global_position.distance_to(center_node.global_position)
		
		var raw_gravity = dir_to_center * (stadium_slope_force * (distance * 0.015)) * state.step
		gravity_velocity_pull = raw_gravity.limit_length(150.0)

	if is_in_group("enemies"):
		# --- AI PHYSICS LOOP ---
		var center_force_vector = Vector2.ZERO 
			
		var player_force_vector = Vector2.ZERO
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0 and is_instance_valid(players[0]):
			var player = players[0]
			var dir_to_player = (player.global_position - global_position).normalized()
			var distance_to_player = global_position.distance_to(player.global_position)
			
			var proximity_factor = clamp(distance_to_player / 300.0, 0.1, 1.0)
			player_force_vector = dir_to_player * enemy_player_track_force * proximity_factor
			
		state.apply_force(center_force_vector + player_force_vector)
		state.linear_velocity += gravity_velocity_pull
	else:
		# --- PLAYER PHYSICS LOOP ---
		var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var player_force = Vector2.ZERO
		
		# COOLDOWN LOCK
		if current_stamina <= 0.0:
			is_overheated = true
		if is_overheated and current_stamina >= max_stamina:
			is_overheated = false

		var is_boosting: bool = Input.is_action_pressed("boost") and current_stamina > 0.0 and not is_overheated
		if is_boosting:
			var current_force = player_control_force * boost_multiplier
			
			if input_dir != Vector2.ZERO:
				player_force = input_dir * current_force
			else:
				player_force = state.linear_velocity.normalized() * current_force
				
			# Drain stamina down
			current_stamina = max(current_stamina - player_boost_cost * state.step, 0.0)
		else:
			# Recharge stamina gradually
			current_stamina = min(current_stamina + stamina_regen_rate * state.step, max_stamina)
			
			if input_dir != Vector2.ZERO:
				player_force = input_dir * player_control_force
				
		state.apply_force(player_force)
		state.linear_velocity += gravity_velocity_pull

func take_damage(amount: float) -> void:
	if is_in_group("enemies"):
		current_health = max(current_health - amount, 0.0)
		print("Enemy took ", int(amount), " damage! Remaining HP: ", current_health)
		
		if current_health <= 0.0:
			die()

func die() -> void:
	print("ENEMY HAS BURST OUT! MATCH OVER.")
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("beys") and body != self:
		
		var relative_velocity = linear_velocity - body.linear_velocity
		var total_impact_speed = relative_velocity.length()
		
		var push_dir = (global_position - body.global_position).normalized()
		
		# KNOCKBACK
		var dynamic_knockback = 120.0 + (total_impact_speed * 0.25)
		apply_central_impulse(push_dir * dynamic_knockback)
		
		# SPEED SANITIZATION
		if linear_velocity.length() > max_player_speed:
			linear_velocity = linear_velocity.normalized() * max_player_speed
		
		if damage_cooldown_timer <= 0.0:
			if is_in_group("player") and body.is_in_group("enemies"):
				var player_speed = linear_velocity.length()
				var enemy_speed = body.linear_velocity.length()
				var damage_to_deal: float = 1.0
				
				if player_speed >= enemy_speed:
					damage_to_deal = clamp(player_speed * 0.015, 1.5, 12.0)
					if has_node("HeavyHitSound"):
						$HeavyHitSound.play()
				else:
					damage_to_deal = 1.0
					if has_node("NormalHitSound"):
						$NormalHitSound.play()
				
				body.take_damage(damage_to_deal)
				damage_cooldown_timer = damage_cooldown_duration
