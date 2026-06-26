extends Control

@onready var _restart_button: Button = $RestartButton
@onready var _resume_button: Button = $ResumeButton
@onready var _quit_button: Button = $QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_resume_button.pressed.connect(_unpause)
	_quit_button.pressed.connect(_quit_game)
	_restart_button.pressed.connect(_on_restart_pressed)

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
	if has_node("ConfirmSound"):
		$ConfirmSound.play()
		await $ConfirmSound.finished
		
	get_tree().paused = false
	visible = false

func _on_restart_pressed() -> void:		
	_unpause()
	
	var stadium = get_tree().current_scene.find_child("Stadium", true, false)
	if stadium and stadium.has_method("start_match"):
		stadium.start_match()

func _quit_game() -> void:
	if has_node("CancelSound"):
		$CancelSound.play()
		await $CancelSound.finished
		
	get_tree().quit()
