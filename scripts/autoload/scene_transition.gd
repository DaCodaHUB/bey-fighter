extends CanvasLayer

var _fade_rect: ColorRect
var _tween: Tween

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	_fade_rect = ColorRect.new()
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.color = Color.BLACK
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.modulate.a = 0.0
	add_child(_fade_rect)


func fade_out(duration: float = 0.4) -> void:
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(_fade_rect, "modulate:a", 1.0, duration)
	await _tween.finished


func fade_in(duration: float = 0.4) -> void:
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(_fade_rect, "modulate:a", 0.0, duration)
	await _tween.finished


func change_scene(path: String, duration: float = 0.4) -> void:
	await fade_out(duration)
	get_tree().change_scene_to_file(path)
	await fade_in(duration)


func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
