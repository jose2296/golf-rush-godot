class_name Player extends RigidBody3D

@export var respawnPosition: Vector3 = Vector3.ZERO
@export var controlType := StateManagement.ControlTypes.keyboard
@export_group('Power')
@export var powerFacotr = 150
@export var maxPower = 200
@export_group("", "")

@export_group('Apparence')
@export var skin := StateManagement.SkinTypes.lava
@export var trail := StateManagement.TrailTypes.basic
@export var accessory := StateManagement.AccessoryTypes.none
@export_group("", "")

@onready var directionBarParent: Node3D = $DirectionBarParent
@onready var directionBar: MeshInstance3D = $DirectionBarParent/DirectionBar
@onready var meshBall: MeshInstance3D = $MeshBall
@onready var power = 0

@onready var powerBar = $PowerBar
@onready var powerProgressBar = $SubViewport/ProgressBar
@onready var accessoryNode = $Accessory

func _ready():
	handleTouchControls()
	powerBar.top_level = true
	powerProgressBar.value = 0
	directionBarParent.top_level = true
	setRespawnNode()
	loadSkin()
	loadAccesory()
	loadTrail()

func setRespawnNode():
	var respawnNode: Node3D = get_tree().get_first_node_in_group('respawn')
	var deathAreaNode: Area3D = get_tree().get_first_node_in_group('deathArea')

	if respawnNode:
		respawnPosition = respawnNode.global_position
		respawnPosition.y += scale.y / 2
	if deathAreaNode:
		deathAreaNode.body_entered.connect(onDeathAreaEntered)
	position = respawnPosition

func handleTouchControls():
	print('Device: %s' % OS.get_model_name())
	if OS.get_model_name() != 'GenericDevice':
		controlType = StateManagement.ControlTypes.touch

	if controlType == StateManagement.ControlTypes.touch:
		var TouchController = preload("res://prefabs/Player/TouchController.tscn")
		var touchControllerInstance = TouchController.instantiate()
		add_child(touchControllerInstance)
		
func loadTrail():
	if trail == StateManagement.TrailTypes.basic:
		var basicTrailScene = preload("res://prefabs/Player/BasicTrail.tscn")
		var basicTrail = basicTrailScene.instantiate()
		add_child(basicTrail)
	
func loadSkin():
	match skin:
		StateManagement.SkinTypes.lava:
			var lavaMateria = preload("res://materials/lava.tres")
			meshBall.material_override = lavaMateria
			directionBar.material_override = lavaMateria
			powerProgressBar.texture_under = preload("res://textures/lava/lavaPowerBarUnder.tres")
			powerProgressBar.texture_progress = preload("res://textures/lava/emissive-1K.png")
		StateManagement.SkinTypes.golf:
			var golfMateria = preload("res://materials/golf.tres")
			meshBall.material_override = golfMateria
			directionBar.material_override = golfMateria
			powerProgressBar.texture_under = preload("res://textures/lava/lavaPowerBarUnder.tres")
			powerProgressBar.texture_progress = preload("res://textures/golf.jpg")
			
func loadAccesory():
	match accessory:
		StateManagement.AccessoryTypes.crown:
			var crownScene = preload("res://prefabs/Player/Accessories/Crown.tscn")
			accessoryNode.add_child(crownScene.instantiate())

func handlePressShoot(delta):
	power += 200 * delta
	if power >= maxPower:
		power = maxPower
		
	var powerPercentage = power * 100 / maxPower
	powerProgressBar.value = powerPercentage
		
func _physics_process(delta):
	if sleeping and controlType == StateManagement.ControlTypes.keyboard:
		if Input.is_action_pressed("left"):
			directionBarParent.rotation_degrees.z = directionBarParent.rotation_degrees.z + (200 * delta)
		if Input.is_action_pressed("right"):
			directionBarParent.rotation_degrees.z = directionBarParent.rotation_degrees.z - (200 * delta)
		if Input.is_action_pressed("shoot"):
			handlePressShoot(delta)
		if Input.is_action_just_released("shoot"):
			shoot()

func _process(delta):
	if controlType == StateManagement.ControlTypes.disabled:
		powerBar.visible = false
		directionBarParent.visible = false
		return
	directionBarParent.visible = sleeping
	powerBar.visible = sleeping
	accessoryNode.position = position
	if sleeping: 
		directionBarParent.position = position
		powerBar.position.x = position.x
		powerBar.position.y = position.y - 1

func shoot():
	var angle = 180 - directionBarParent.rotation_degrees.z
	var powerPercentage = power * 100 / maxPower
	var impulseX = cos(deg_to_rad(angle)) * (powerPercentage / 100) * powerFacotr;
	var impulseY = sin(deg_to_rad(angle)) * (powerPercentage / 100) * powerFacotr;
	apply_central_impulse(Vector3(-impulseX, impulseY, 0))
	#material_override.albedo_color = Color.RED
	print('SHOOT => angle: ' + str(angle) + ', power: ' + str(powerPercentage))
	power = 0
	powerProgressBar.value = 0

func onDeathAreaEntered(body):
	position = respawnPosition
	linear_velocity = Vector3(0, 0, 0)
	angular_velocity = Vector3(0, 0, 0)
