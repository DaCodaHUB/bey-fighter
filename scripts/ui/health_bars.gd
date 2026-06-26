extends Control

const TIME_LAPSE: float = 40.0
var match_time_left: float = GlobalSettings.match_duration
var is_match_active: bool = false 

func _ready() -> void:
	var stadium = get_tree().current_scene.get_node_or_null("Stadium")
	if stadium:
		stadium.blade_reset.connect(_on_stadium_blade_reset)

func _on_stadium_blade_reset() -> void:
	match_time_left = TIME_LAPSE
	is_match_active = false
	if has_node("GameStatus"):
		$GameStatus.text = "PRESS START TO PLAY" # Standard white text by default

func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	var enemies = get_tree().get_nodes_in_group("enemies")

	# --- TIMER LOGIC ---
	if is_match_active:
		match_time_left = max(match_time_left - delta, 0.0)
		if has_node("GameStatus"):
			$GameStatus.text = str(int(match_time_left))
		
		# TIME RUNS OUT
		if match_time_left <= 0.0:
			is_match_active = false
			if has_node("GameStatus"):
				# 🌟 Clear the theme block and apply red
				$GameStatus.remove_theme_color_override("default_color")
				$GameStatus.text = "[color=#ff0000]Lose[/color]"
				
				if players.size() > 0 and is_instance_valid(players[0]):
					players[0].queue_free()
					
	else:
		if has_node("GameStatus") and match_time_left <= 0.0:
			$GameStatus.remove_theme_color_override("default_color")
			if enemies.size() > 0 or $EnemyHP/EnemyBarFill.value > 0:
				if $EnemyHP/EnemyBarFill.value == 0:
					$GameStatus.text = "[color=#00ff00]Win[/color]"
				else:
					$GameStatus.text = "[color=#ff0000]Lose[/color]"
			else:
				$GameStatus.text = "[color=#00ff00]Win[/color]"

	# START GAME CLOCK
	if not is_match_active and match_time_left > 0.0 and players.size() > 0 and enemies.size() > 0:
		is_match_active = true

	# ENEMY BURST
	if is_match_active and match_time_left > 0.0:
		if enemies.size() == 0 or (enemies.size() > 0 and not is_instance_valid(enemies[0])):
			is_match_active = false
			if has_node("GameStatus"):
				# 🌟 Clear the theme block and apply green
				$GameStatus.remove_theme_color_override("default_color")
				$GameStatus.text = "[color=#00ff00]Win[/color]"

	# --- PLAYER STAMINA UI ---
	if has_node("PlayerStamina/PlayerStaminaFill"):
		if players.size() > 0 and is_instance_valid(players[0]):
			$PlayerStamina/PlayerStaminaFill.value = (players[0].current_stamina / players[0].max_stamina) * 100
		else:
			if match_time_left == TIME_LAPSE:
				$PlayerStamina/PlayerStaminaFill.value = 100
			elif match_time_left <= 0.0:
				$PlayerStamina/PlayerStaminaFill.value = 0

	# --- ENEMY HEALTH UI ---
	if has_node("EnemyHP/EnemyBarFill"):
		if enemies.size() > 0 and is_instance_valid(enemies[0]):
			$EnemyHP/EnemyBarFill.value = (enemies[0].current_health / enemies[0].max_health) * 100
		else:
			if match_time_left == TIME_LAPSE:
				$EnemyHP/EnemyBarFill.value = 100
			else:
				if match_time_left > 0.0 and is_match_active:
					$EnemyHP/EnemyBarFill.value = 0
