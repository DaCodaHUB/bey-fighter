extends Control

var match_time_left: float = 30.0
var is_match_active: bool = false 

func _ready() -> void:
	var stadium = get_tree().current_scene.get_node_or_null("Stadium")
	if stadium:
		stadium.blade_reset.connect(_on_stadium_blade_reset)

func _on_stadium_blade_reset() -> void:
	match_time_left = 30.0
	is_match_active = false

func _process(delta: float) -> void:
	# --- GET ACTIVE ENTITIES ---
	var players = get_tree().get_nodes_in_group("player")
	var enemies = get_tree().get_nodes_in_group("enemies")

	# --- TIMER LOGIC ---
	if is_match_active:
		match_time_left = max(match_time_left - delta, 0.0)
		if has_node("GameStatus"):
			$GameStatus.text = "TIME: " + String.num(match_time_left, 1)
		
		# TIME EXPIRED
		if match_time_left <= 0.0:
			is_match_active = false
			
			# Check if the enemy survived the clock
			if enemies.size() > 0 and is_instance_valid(enemies[0]) and enemies[0].current_health > 0.0:
				if has_node("GameStatus"):
					$GameStatus.text = "TIME'S UP! ENEMY WINS"
					
				if players.size() > 0 and is_instance_valid(players[0]):
					players[0].queue_free()
			else:
				if has_node("GameStatus"):
					$GameStatus.text = "TIME'S UP! GAME OVER"
	else:
		if has_node("GameStatus"):
			if match_time_left <= 0.0:
				if enemies.size() > 0 or $EnemyHP/EnemyBarFill.value > 0:
					if $EnemyHP/EnemyBarFill.value == 0:
						$GameStatus.text = "ENEMY BURST! YOU WIN"
					else:
						$GameStatus.text = "TIME'S UP! ENEMY WINS"
				else:
					$GameStatus.text = "ENEMY BURST! YOU WIN"
			elif match_time_left == 30.0:
				$GameStatus.text = "PRESS ENTER TO START"

	if match_time_left == 30.0 and players.size() > 0 and enemies.size() > 0:
		is_match_active = true

	# --- PLAYER STAMINA UI ---
	if has_node("PlayerStamina/PlayerStaminaFill"):
		if players.size() > 0 and is_instance_valid(players[0]):
			$PlayerStamina/PlayerStaminaFill.value = (players[0].current_stamina / players[0].max_stamina) * 100
		else:
			if match_time_left == 30.0:
				$PlayerStamina/PlayerStaminaFill.value = 100
			elif match_time_left <= 0.0:
				$PlayerStamina/PlayerStaminaFill.value = 0

	# --- ENEMY HEALTH UI ---
	if has_node("EnemyHP/EnemyBarFill"):
		if enemies.size() > 0 and is_instance_valid(enemies[0]):
			$EnemyHP/EnemyBarFill.value = (enemies[0].current_health / enemies[0].max_health) * 100
		else:
			if match_time_left == 30.0:
				$EnemyHP/EnemyBarFill.value = 100
			else:
				if match_time_left > 0.0 and is_match_active:
					$EnemyHP/EnemyBarFill.value = 0
					is_match_active = false
					if has_node("GameStatus"):
						$GameStatus.text = "ENEMY BURST! YOU WIN"
