extends RigidBody2D

@export var max_spin_speed: float = 70.0
@export var stadium_slope_force: float = 400.0
@export var launch_force_min: float = 300.0
@export var launch_force_max: float = 600.0

var center_node: Marker2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
				
	# Randomize launch spin direction and speed
	angular_velocity = randf_range(max_spin_speed - 10, max_spin_speed) * (1 if randf() > 0.5 else -1)
	
	# Find stadium center
	center_node = get_parent().get_node_or_null("Stadium/CenterPoint")
	
	# Randomize initial velocity
	var random_angle = randf_range(0, 2 * PI)
	var launch_direction = Vector2(cos(random_angle), sin(random_angle))
	var random_speed = randf_range(launch_force_min, launch_force_max)
	
	# Apply an instantaneous kick right at frame one
	linear_velocity = launch_direction * random_speed

func _physics_process(delta: float) -> void:
	# Spin visual graphic
	sprite.rotate(angular_velocity * delta)
	
	# Stadium Gravity
	if center_node:
		var dir_to_center = (center_node.global_position - global_position).normalized()
		var distance = global_position.distance_to(center_node.global_position)
		
		# Linear calculation ensures a steady, powerful draw into the bowl center
		apply_central_force(dir_to_center * stadium_slope_force * (distance * 0.01))
		
	# Check for Stamina Loss
	if abs(angular_velocity) < 0.2:
		print(name + " has stopped spinning!")
		queue_free()

func _on_body_entered(body: Node) -> void:
	# Check if the thing we smashed into is another Beyblade
	if body is RigidBody2D and body.is_in_group("beyblades") or "Beyblade" in body.name:
		# Calculate the directional vector pointing away from the opponent
		var push_dir = (global_position - body.global_position).normalized()
		
		# Combine both Beyblades' rotational speeds to determine the impact force
		var total_spin_force = abs(angular_velocity) + abs(body.angular_velocity)
		
		# Apply a massive instantaneous impulse to launch them apart!
		var impact_power = total_spin_force * 12.0
		apply_central_impulse(push_dir * impact_power)
		
		# Real Beyblades lose stamina when they smash together!
		# Reduce spin speed by 15% on heavy impact
		angular_velocity *= 0.85
