extends StaticBody2D

var beybladeScene = preload("res://scenes/beyblade.tscn")

var localCollisionRect: Rect2
var globalCollisionRect: Rect2

var transform_vector = Vector2(920, 600)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	global_position = Vector2(transform_vector.x, transform_vector.y)
	
	localCollisionRect = Rect2($BoundingCircle.polygon[0], Vector2.ZERO)

	for p in $BoundingCircle.polygon:
		localCollisionRect = localCollisionRect.expand(p)
	print("local collision Size:", localCollisionRect.size)		
	
	#globalCollisionRect = Rect2(
		#Vector.ZERO,
		#localCollisionRect.size.x + transform_vector.x,
		#localCollisionRect.size.y + transform_vector.y
	#)
	#print("global collision size:", globalCollisionRect.size)		



	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_global = get_global_mouse_position()
			var center_global = $CenterPoint.global_position
			
			var distance = mouse_global.distance_to(center_global)
			print("Distance to center: ", distance, " | Allowed Radius: ", $BoundingCircle.radius)
			
			if distance < $BoundingCircle.radius:                    
				var newBlade = beybladeScene.instantiate()
				# Set position in absolute world space
				newBlade.global_position = mouse_global
				
				# Add it to the main scene tree directly so it moves freely
				get_tree().current_scene.add_child(newBlade)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
