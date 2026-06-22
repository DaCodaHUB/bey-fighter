extends CanvasLayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("buffs: ", GameState.buffs)
	print("debuffs: ", GameState.debuffs)
	
	for buff in GameState.buffs:
		var label = Label.new()
		label.text = buff
		
		$BuffContainer.add_child(label)
		
	for debuff in GameState.debuffs:
		var label = Label.new()
		label.text = debuff
		$DebuffContainer.add_child(label)
		
	
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
