extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for buff in GameState.buffs:
		var label = Label.new()
		label.text = buff
		add_child(label)
