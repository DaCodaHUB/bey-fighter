@tool 
extends CollisionPolygon2D

@export var generate_circle: bool = false:
	set(val):
		_build_circle()

@export var radius: float:
	set(val):
		radius = val
		_build_circle()

@export var vertex_count: int = 32: # Higher = smoother circle
	set(val):
		vertex_count = max(3, val)
		_build_circle()

func _build_circle() -> void:
	var new_points = PackedVector2Array()
	
	for i in range(vertex_count):
		# Calculate angle for this specific point around the circle
		var angle = i * (2 * PI / vertex_count)
		# Use trigonometry to find the X and Y coordinates
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		new_points.append(Vector2(x, y))
		
	polygon = new_points
