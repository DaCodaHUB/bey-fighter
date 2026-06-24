extends Label

var isOver = false

func _ready() -> void:
	get_node("/root/Main/Game/Stadium").blade_reset.connect(_on_blade_reset)

func _on_blade_reset():
	self.text = "GAME READY"
	# Reset back to white text
	if self.label_settings:
		self.label_settings.font_color = Color.WHITE
	isOver = false

func _process(_delta: float) -> void:
	if isOver:
		return
		
	# Find the current state of both combatants
	var players = get_tree().get_nodes_in_group("player")
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	var is_player_alive = players.size() > 0 and is_instance_valid(players[0])
	var is_enemy_alive = enemies.size() > 0 and is_instance_valid(enemies[0])
	
	if is_player_alive and is_enemy_alive:
		if self.text == "GAME READY":
			self.text = "GAME IN PROGRESS"

	elif self.text == "GAME IN PROGRESS":
		var labelSetting = LabelSettings.new()
		
		if not is_player_alive:
			self.text = "GAME OVER"
			labelSetting.font_color = Color.RED
			isOver = true
			
		elif not is_enemy_alive:
			self.text = "YOU WON!"
			labelSetting.font_color = Color.YELLOW
			isOver = true
			
		self.label_settings = labelSetting
