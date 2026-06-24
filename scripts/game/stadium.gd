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
				# --- TOTAL ARENA CLEANUP USING GROUPS ---
				var active_players = get_tree().get_nodes_in_group("player")
				for p in active_players:
					p.remove_from_group("player") # Instantly untag it so UI ignores it
					p.queue_free()
					
				var active_enemies = get_tree().get_nodes_in_group("enemies")
				for e in active_enemies:
					e.remove_from_group("enemies") # Instantly untag it so UI ignores it
					e.queue_free()
					
				blade_reset.emit()
				
				# --- DEFINE SAFE BOUNDS AND SPAWN NEW BLADES ---
				var min_spawn_dist = 100.0
				var max_spawn_dist = $BoundingCircle.radius - 50.0
				
				# --- RANDOMIZE USER POSITION (Bottom Half) ---
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
				var enemy_angle = randf_range(PI, 2.0 * PI)
				var enemy_dist = randf_range(min_spawn_dist, max_spawn_dist)
				var enemy_offset = Vector2(cos(enemy_angle), sin(enemy_angle)) * enemy_dist
				
				var enemy_blade = beybladeScene.instantiate()
				enemy_blade.name = "EnemyBlade"
				enemy_blade.add_to_group("enemies")
				enemy_blade.global_position = center_global + enemy_offset
				get_tree().current_scene.add_child(enemy_blade)
				blade_created.emit("Enemy", enemy_blade)

func _process(delta: float) -> void:
	pass
