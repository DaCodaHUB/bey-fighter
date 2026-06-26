extends Control

func _process(_delta: float) -> void:
	if has_node("../Inputs"):
		_update_key_display("../Inputs/KeyW/WBackground", "../Inputs/KeyW/Label", "move_up")
		_update_key_display("../Inputs/KeyA/ABackground", "../Inputs/KeyA/Label", "move_left")
		_update_key_display("../Inputs/KeyS/SBackground", "../Inputs/KeyS/Label", "move_down")
		_update_key_display("../Inputs/KeyD/DBackground", "../Inputs/KeyD/Label", "move_right")
		_update_key_display("../Inputs/KeySpace/SpaceBackground", "../Inputs/KeySpace/Label", "boost")

func _update_key_display(bg_path: String, label_path: String, action_name: String) -> void:
	if has_node(bg_path) and has_node(label_path):
		var bg = get_node(bg_path) as ColorRect
		
		if Input.is_action_pressed(action_name):
			bg.visible = true
		else:
			bg.visible = false
