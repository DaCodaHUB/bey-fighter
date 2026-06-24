extends StaticBody2D

var beybladeScene = preload("res://scenes/beyblade.tscn")

var localCollisionRect: Rect2
var globalCollisionRect: Rect2

var transform_vector = Vector2(920, 600)

signal blade_created(role, blade)
signal blade_reset()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	global_position = Vector2(transform_vector.x, transform_vector.y)
	
	localCollisionRect = Rect2($BoundingCircle.polygon[0], Vector2.ZERO)

	for p in $BoundingCircle.polygon:
		localCollisionRect = localCollisionRect.expand(p)
	print("local collision Size:", localCollisionRect.size)		

	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_global = get_global_mouse_position()
			var center_global = $CenterPoint.global_position
			
			var distance = mouse_global.distance_to(center_global)
			
			if distance < $BoundingCircle.radius:
				# Clear previous match remnants
				var prevPlayerBlade = get_tree().current_scene.get_node("PlayerBlade")
				if prevPlayerBlade:
					prevPlayerBlade.free()
				var prevEnemyBlade = get_tree().current_scene.get_node("EnemyBlade")
				if prevEnemyBlade:
					prevEnemyBlade.free()
					
				blade_reset.emit()
				
				# Define safe bounds so they don't spawn right on the wall or dead-center
				var min_spawn_dist = 100.0
				var max_spawn_dist = $BoundingCircle.radius - 50.0
				
				# --- RANDOMIZE USER POSITION (Bottom Half) ---
				# Angles from 0 to PI radians point downwards in Godot's 2D coordinate space
				var user_angle = randf_range(0.0, PI)
				var user_dist = randf_range(min_spawn_dist, max_spawn_dist)
				var user_offset = Vector2(cos(user_angle), sin(user_angle)) * user_dist
				
				var user_blade = beybladeScene.instantiate()
				user_blade.name = "PlayerBlade"
				user_blade.add_to_group("player")
				user_blade.global_position = center_global + user_offset
				get_tree().current_scene.add_child(user_blade)
				blade_created.emit("Player", user_blade)
				
				# --- RANDOMIZE ENEMY POSITION (Top Half) ---
				# Angles from PI to 2*PI radians point upwards
				var enemy_angle = randf_range(PI, 2.0 * PI)
				var enemy_dist = randf_range(min_spawn_dist, max_spawn_dist)
				var enemy_offset = Vector2(cos(enemy_angle), sin(enemy_angle)) * enemy_dist
				
				var enemy_blade = beybladeScene.instantiate()
				enemy_blade.name = "EnemyBlade"
				enemy_blade.add_to_group("enemies")
				enemy_blade.global_position = center_global + enemy_offset
				get_tree().current_scene.add_child(enemy_blade)
				blade_created.emit("Enemy", enemy_blade)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
