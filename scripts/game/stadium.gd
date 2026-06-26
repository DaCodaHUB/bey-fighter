extends StaticBody2D

var beybladeScene = preload("res://scenes/beyblade.tscn")

var localCollisionRect: Rect2
var globalCollisionRect: Rect2

signal blade_created(role, blade)
signal blade_reset()

var user_blade
var enemy_blade

func _ready() -> void:
	localCollisionRect = Rect2($BoundingCircle.polygon[0], Vector2.ZERO)

	for p in $BoundingCircle.polygon:
		localCollisionRect = localCollisionRect.expand(p)
	print("local collision Size:", localCollisionRect.size)     
	
	var stadium_material = PhysicsMaterial.new()
	stadium_material.bounce = 0.0
	stadium_material.friction = 0.1
	physics_material_override = stadium_material   

	var center_global = $CenterPoint.global_position
	var center_local = $CenterPoint.position
	print("Center point global_position: ", center_global)
	print("Center point position: ", center_local)
	
	print("Ready to spawn player and enemy")
	
	# --- SAFE BOUNDS ---
	var min_spawn_dist = 100.0
	var max_spawn_dist = $BoundingCircle.radius - 50.0
	
	# --- RANDOMIZE USER POSITION (Bottom Half) ---
	var user_angle = randf_range(0.0, PI)
	var user_dist = randf_range(min_spawn_dist, max_spawn_dist)
	var user_offset = Vector2(cos(user_angle), sin(user_angle)) * user_dist
		
	user_blade = beybladeScene.instantiate()
	user_blade.name = "PlayerBlade"
	user_blade.add_to_group("player")
	user_blade.position = center_local + user_offset
	print("User blade global position: ", user_blade.global_position)
	
	if user_blade.has_node("Sprite2D"):
		user_blade.get_node("Sprite2D").texture = load("res://assets/ui/beychip-25.png")
	
	add_child(user_blade)
	blade_created.emit("Player", user_blade)
	
	# --- RANDOMIZE ENEMY POSITION (Top Half) ---
	var enemy_angle = randf_range(PI, 2.0 * PI)
	var enemy_dist = randf_range(min_spawn_dist, max_spawn_dist)
	var enemy_offset = Vector2(cos(enemy_angle), sin(enemy_angle)) * enemy_dist
	
	var enemy_blade = beybladeScene.instantiate()
	enemy_blade.name = "EnemyBlade"
	enemy_blade.add_to_group("enemies")
	enemy_blade.position = center_local + enemy_offset
	print("Enemy blade global position: ", enemy_blade.global_position)

	if enemy_blade.has_node("Sprite2D"):
		enemy_blade.get_node("Sprite2D").texture = load("res://assets/ui/beychip-5.png")
	
	add_child(enemy_blade)
	blade_created.emit("Enemy", enemy_blade)
	
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("start"): 
		var center_global = $CenterPoint.global_position
		
		# --- ARENA CLEANUP ---
		#var active_players = get_tree().get_nodes_in_group("player")
		#for p in active_players:
			#p.remove_from_group("player") 
			#p.queue_free()
			#
		#var active_enemies = get_tree().get_nodes_in_group("enemies")
		#for e in active_enemies:
			#e.remove_from_group("enemies") 
			#e.queue_free()
			#
		#blade_reset.emit()
		
		# TIMER
		var root = get_tree().current_scene
		var ui_node = root.find_child("HealthBars", true, false)
		if ui_node:
			ui_node.match_time_left = 30.0
			ui_node.is_match_active = false
		
		## --- SAFE BOUNDS ---
		#var min_spawn_dist = 100.0
		#var max_spawn_dist = $BoundingCircle.radius - 50.0
		#
		## --- RANDOMIZE USER POSITION (Bottom Half) ---
		#var user_angle = randf_range(0.0, PI)
		#var user_dist = randf_range(min_spawn_dist, max_spawn_dist)
		#var user_offset = Vector2(cos(user_angle), sin(user_angle)) * user_dist
		
		#var user_blade = beybladeScene.instantiate()
		#user_blade.name = "PlayerBlade"
		#user_blade.add_to_group("player")
		#user_blade.global_position = center_global + user_offset
		#
		#if user_blade.has_node("Sprite2D"):
			#user_blade.get_node("Sprite2D").texture = load("res://assets/ui/beychip-25.png")
		#
		#get_tree().current_scene.add_child(user_blade)
		#blade_created.emit("Player", user_blade)
		
		## --- RANDOMIZE ENEMY POSITION (Top Half) ---
		#var enemy_angle = randf_range(PI, 2.0 * PI)
		#var enemy_dist = randf_range(min_spawn_dist, max_spawn_dist)
		#var enemy_offset = Vector2(cos(enemy_angle), sin(enemy_angle)) * enemy_dist
		#
		#var enemy_blade = beybladeScene.instantiate()
		#enemy_blade.name = "EnemyBlade"
		#enemy_blade.add_to_group("enemies")
		#enemy_blade.global_position = center_global + enemy_offset
		#
		#if enemy_blade.has_node("Sprite2D"):
			#enemy_blade.get_node("Sprite2D").texture = load("res://assets/ui/beychip-5.png")
		#
		#get_tree().current_scene.add_child(enemy_blade)
		#blade_created.emit("Enemy", enemy_blade)
