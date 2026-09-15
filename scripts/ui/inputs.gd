extends Control

var _normal_textures: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is TouchScreenButton:
			_normal_textures[child] = child.texture_normal
			var label := child.get_node_or_null("Label") as Label
			if label:
				label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_button_display()

func _process(_delta: float) -> void:
	_update_button_display()

func _update_button_display() -> void:
	for node in _normal_textures:
		var button := node as TouchScreenButton
		var active := button.is_pressed()
		if not button.action.is_empty():
			active = active or Input.is_action_pressed(button.action)
		# Keyboard actions don't set the button's internal touch-pressed state.
		if active and button.texture_pressed != null:
			button.texture_normal = button.texture_pressed
		else:
			button.texture_normal = _normal_textures[button]
		var label := button.get_node_or_null("Label") as Label
		if label:
			label.add_theme_color_override("font_color", Color.BLACK if active else Color.WHITE)
