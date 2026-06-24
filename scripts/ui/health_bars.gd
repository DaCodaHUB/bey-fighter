extends HBoxContainer

var max_value = 100

var playerBladeRef: RigidBody2D
var enemyBladeRef: RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("/root/Main/Game/Stadium").blade_created.connect(_on_blade_created)
	get_node("/root/Main/Game/Stadium").blade_reset.connect(_on_blade_reset)

func _on_blade_created(role, blade):
	if role == "Player":
		playerBladeRef = blade
	elif role == "Enemy":
		enemyBladeRef = blade
	
	if playerBladeRef:
		print("Player hp: ", playerBladeRef.current_health)
		playerBladeRef.health_changed.connect(_on_health_changed)
	if enemyBladeRef:
		print("Enemy hp: ", enemyBladeRef.current_health)
		enemyBladeRef.health_changed.connect(_on_health_changed)
	
func _on_blade_reset():
	update_health_bar("Player", 100, 100)
	update_health_bar("Enemy", 100, 100)
	
func _on_health_changed(role, amount, current_health, max_health):
	print("health changed > role=", role, ", hp=", current_health, ", max=", max_health)
	update_health_bar(role, current_health, max_health)


func update_health_bar(role, current_health, max_health):
	var newProgress = (current_health / max_health) * max_value
	if role == "Player":
		$PlayerHP.value = newProgress
	elif role == "Enemy":
		$EnemyHP.value = newProgress
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
