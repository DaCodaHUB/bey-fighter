extends HBoxContainer

func _process(_delta: float) -> void:
	# Check if we are still waiting for the match to start
	var is_game_ready = $GameStatus.text == "GAME READY"
	var empty_fallback = 100 if is_game_ready else 0 

	# Player HP Logic
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and is_instance_valid(players[0]):
		$PlayerHP.value = (players[0].current_health / players[0].max_health) * 100
	else:
		$PlayerHP.value = empty_fallback
		
	# Enemy HP Logic
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0 and is_instance_valid(enemies[0]):
		$EnemyHP.value = (enemies[0].current_health / enemies[0].max_health) * 100
	else:
		$EnemyHP.value = empty_fallback
