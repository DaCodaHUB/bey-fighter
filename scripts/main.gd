extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collisionBox: CollisionPolygon2D = $Stadium/BoundingCircle
	var rect := Rect2(collisionBox.polygon[0], Vector2.ZERO)
	
	for p in collisionBox.polygon:
		rect = rect.expand(p)

	print("Stadium Size:", rect.size)		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
