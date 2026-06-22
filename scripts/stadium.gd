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
			var localPos = get_local_mouse_position()
			print("local mouse pos: ", localPos)
			if (localPos.distance_to($CenterPoint.position) < $BoundingCircle.radius):					
				var newBlade = beybladeScene.instantiate()
				#newBlade.position = Vector2(
					#localPos.position.x ,
					#localPos.position.y
				#)
				newBlade.position = localPos
				add_child(newBlade)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
