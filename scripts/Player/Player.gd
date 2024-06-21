class_name Player extends RigidBody3D

enum ControlTypes {
	keyboard,
	touch,
	disabled
}

enum TrailTypes {
	none,
	basic
}
enum SkinTypes {
	lava
}

@export var respawnPosition: Vector3 = Vector3.ZERO
@export var controlType: ControlTypes = ControlTypes.keyboard
@export_group('Power')
@export var powerFacotr = 150
@export var maxPower = 200
@export_group("", "")

@export_group('Apparence')
@export var skin: SkinTypes = SkinTypes.lava
@export var trail: TrailTypes = TrailTypes.basic
@export_group("", "")

@onready var directionBarParent: Node3D = $DirectionBarParent
@onready var directionBar: MeshInstance3D = $DirectionBarParent/DirectionBar
@onready var powerBar: PowerBar = $PowerBar
@onready var powerBarValue: MeshInstance3D = $PowerBar/Value
@onready var meshBall: MeshInstance3D = $MeshBall
@onready var power = 0

func _ready():
	if controlType == ControlTypes.touch:
		var TouchController = preload("res://scenes/Player/TouchController.tscn")
		var touchControllerInstance = TouchController.instantiate()
		add_child(touchControllerInstance)
	powerBar.top_level = true
	directionBarParent.top_level = true
	var respawnNode = $"../Respawn"
	if respawnNode:
		respawnPosition = $"../Respawn".position
		respawnPosition.y += scale.y / 2
	position = respawnPosition
	loadSkin()
	loadTrail()
	
func loadTrail():
	if trail == TrailTypes.basic:
		var basicTrailScene = preload("res://scenes/Player/BasicTrail.tscn")
		var basicTrail = basicTrailScene.instantiate()
		add_child(basicTrail)
	
func loadSkin():
	if skin == SkinTypes.lava:
		var lavaMateria = preload("res://materials/lava.tres")
		meshBall.material_override = lavaMateria
		directionBar.material_override = lavaMateria
		powerBarValue.material_override = preload("res://materials/lavaTriplanar.tres")
	
func handlePressShoot(delta):
	power += 200 * delta
	if power >= maxPower:
		power = maxPower
		
	var powerPercentage = power * 100 / maxPower
	powerBar.updateValue(powerPercentage)
		
func _physics_process(delta):
	if sleeping and controlType == ControlTypes.keyboard:
		if Input.is_action_pressed("left"):
			directionBarParent.rotation_degrees.z = directionBarParent.rotation_degrees.z + (200 * delta)
		if Input.is_action_pressed("right"):
			directionBarParent.rotation_degrees.z = directionBarParent.rotation_degrees.z - (200 * delta)
		if Input.is_action_pressed("shoot"):
			handlePressShoot(delta)
		if Input.is_action_just_released("shoot"):
			shoot()

func _process(delta):
	directionBarParent.visible = sleeping
	powerBar.visible = sleeping
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
	powerBar.updateValue(0)

func _on_death_area_body_entered(body):
	position = respawnPosition
	linear_velocity = Vector3(0, 0, 0)
	angular_velocity = Vector3(0, 0, 0)