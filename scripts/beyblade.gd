extends RigidBody2D

@export var max_health: float = 100.0
var current_health: float

@export var constant_spin_speed: float = 60.0
@export var stadium_slope_force: float = 400.0

@export var player_control_force: float = 700.0
@export var max_player_speed: float = 600.0
@export var boost_multiplier: float = 2.0

# AI Tuning Variables
@export var enemy_center_pull_force: float = 600.0  # Primary focus
@export var enemy_player_track_force: float = 600.0 # Secondary nudge

var center_node: Marker2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	current_health = max_health
	
	# Set a constant, locked physics spin speed
	angular_velocity = constant_spin_speed * (1 if randf() > 0.5 else -1)
	
	# Turn off angular dampening completely so friction won't slow the spin
	angular_damp = 0.0
	
	center_node = get_parent().get_node_or_null("Stadium/CenterPoint")

func _physics_process(delta: float) -> void:
	angular_velocity = constant_spin_speed * sign(angular_velocity)
	sprite.rotate(angular_velocity * delta)
	
	# Universal Base Gravity
	if center_node:
		var dir_to_center = (center_node.global_position - global_position).normalized()
		var distance = global_position.distance_to(center_node.global_position)
		apply_central_force(dir_to_center * stadium_slope_force * (distance * 0.01))

	# Role Differentiation
	if is_in_group("enemies"):
		# AI LOGIC
		var center_force_vector = Vector2.ZERO
		if center_node:
			var dir_to_center = (center_node.global_position - global_position).normalized()
			center_force_vector = dir_to_center * enemy_center_pull_force
			
		# Nudge toward the player's position
		var player_force_vector = Vector2.ZERO
		
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var player = players[0]
			if is_instance_valid(player):
				var dir_to_player = (player.global_position - global_position).normalized()
				var distance_to_player = global_position.distance_to(player.global_position)
				
				# --- DYNAMIC TRACKING ---
				# If far away, use full tracking force. 
				# As it gets closer than 300 pixels, smoothly reduce the tracking force!
				var proximity_factor = clamp(distance_to_player / 300.0, 0.1, 1.0)
				var scaled_track_force = enemy_player_track_force * proximity_factor
				
				player_force_vector = dir_to_player * scaled_track_force
			
		apply_central_force(center_force_vector + player_force_vector)
		
	else:
		# PLAYER CONTROL LOGIC
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		if input_dir != Vector2.ZERO or Input.is_action_pressed("boost"):
			var current_force = player_control_force
			
			if Input.is_action_pressed("boost"):
				current_force *= boost_multiplier
			
			if input_dir != Vector2.ZERO:
				apply_central_force(input_dir * current_force)
		
		# --- TOP SPEED CAP ---
		# Check how fast the player is physically sliding across the screen
		if linear_velocity.length() > max_player_speed:
			# Clamp the velocity vector back down to your maximum allowed speed limit
			linear_velocity = linear_velocity.normalized() * max_player_speed

func take_damage(amount: float) -> void:
	current_health -= amount
	print(name, " took ", amount, " damage! HP remaining: ", current_health)
	
	if current_health <= 0:
		explode_or_destroy()

func explode_or_destroy() -> void:
	print(name, " HAS BURST!")
	# Code to trigger particles or pieces flying apart later goes here
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("beys"):
		# Knockback Physics
		var push_dir = (global_position - body.global_position).normalized()
		var explosion_force = 800.0
		apply_central_impulse(push_dir * explosion_force)
		
		# Calculate Damage based on how hard they hit
		var impact_speed = linear_velocity.length()
		var damage_dealt = clamp(impact_speed * 0.05, 5.0, 25.0) # Deals between 5 and 25 damage
		
		# Apply the damage!
		take_damage(damage_dealt)
