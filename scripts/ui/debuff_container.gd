extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		
	for debuff in GameState.debuffs:
		var label = Label.new()
		label.text = debuff
		add_child(label)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
