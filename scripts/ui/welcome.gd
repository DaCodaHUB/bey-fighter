extends Control

@onready var _start_button: Button = $CenterContainer/VBoxContainer/StartGameButton
@onready var _quit_button: Button = $CenterContainer/VBoxContainer/QuitGameButton


func _ready() -> void:
	_start_button.pressed.connect(_on_start_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func _on_start_pressed() -> void:
	print("Button start clicked")
	SceneTransition.change_scene("res://scenes/main.tscn")


func _on_quit_pressed() -> void:
	print("Button quit clicked")
	get_tree().quit()
