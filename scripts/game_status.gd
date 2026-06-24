extends Label

var playerBladeRef: RigidBody2D
var enemyBladeRef: RigidBody2D

var isOver = false

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
		playerBladeRef.health_changed.connect(_on_health_changed)
	if enemyBladeRef:
		enemyBladeRef.health_changed.connect(_on_health_changed)
	
func _on_blade_reset():
	self.text = "GAME READY"
	isOver = false

func _on_health_changed(role, amount, current_health, max_health):
	if !isOver:
		var labelSetting = LabelSettings.new()
		self.text = "GAME IN PROGRESS"

		if role == "Player" and current_health <= 0.0:
			self.text = "GAME OVER"
			labelSetting.font_color = Color.RED 
			isOver = true
		if role == "Enemy" and current_health <= 0.0:
			self.text = "YOU WON!"
			labelSetting.font_color = Color.YELLOW 
			
		self.label_settings = labelSetting

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
