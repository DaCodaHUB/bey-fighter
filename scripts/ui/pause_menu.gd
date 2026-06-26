extends Control

@onready var _resume_button: Button = $CenterContainer/VBoxContainer/ResumeButton
@onready var _quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_resume_button.pressed.connect(_unpause)
	_quit_button.pressed.connect(_quit_game)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	if get_tree().paused:
		_unpause()
	else:
		_pause()


func _pause() -> void:
	get_tree().paused = true
	visible = true


func _unpause() -> void:
	get_tree().paused = false
	visible = false

func _quit_game() -> void:
	get_tree().quit()
