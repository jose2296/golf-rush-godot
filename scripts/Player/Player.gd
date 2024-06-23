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
	lava,
	golf
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
@onready var meshBall: MeshInstance3D = $MeshBall
@onready var power = 0


@onready var power_bar_v_2 = $"PowerBar V2"
@onready var powerBarV2 = $SubViewport/ProgressBar

func _ready():
	print('TEST ADNROID')
	if controlType == ControlTypes.touch:
		var TouchController = preload("res://prefabs/Player/TouchController.tscn")
		var touchControllerInstance = TouchController.instantiate()
		add_child(touchControllerInstance)
	power_bar_v_2.top_level = true
	powerBarV2.value = 0
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
		var basicTrailScene = preload("res://prefabs/Player/BasicTrail.tscn")
		var basicTrail = basicTrailScene.instantiate()
		add_child(basicTrail)
	
func loadSkin():
	match skin:
		SkinTypes.lava:
			var lavaMateria = preload("res://materials/lava.tres")
			meshBall.material_override = lavaMateria
			directionBar.material_override = lavaMateria
			powerBarV2.texture_under = preload("res://textures/lava/lavaPowerBarUnder.tres")
			powerBarV2.texture_progress = preload("res://textures/lava/emissive-1K.png")
		SkinTypes.golf:
			var golfMateria = preload("res://materials/golf.tres")
			meshBall.material_override = golfMateria
			directionBar.material_override = golfMateria
			powerBarV2.texture_under = preload("res://textures/lava/lavaPowerBarUnder.tres")
			powerBarV2.texture_progress = preload("res://textures/golf.jpg")
			
func handlePressShoot(delta):
	power += 200 * delta
	if power >= maxPower:
		power = maxPower
		
	var powerPercentage = power * 100 / maxPower
	powerBarV2.value = powerPercentage
		
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
	if controlType == ControlTypes.disabled:
		power_bar_v_2.visible = false
		directionBarParent.visible = false
		return
	directionBarParent.visible = sleeping
	power_bar_v_2.visible = sleeping
	if sleeping: 
		directionBarParent.position = position
		power_bar_v_2.position.x = position.x
		power_bar_v_2.position.y = position.y - 1

func shoot():
	var angle = 180 - directionBarParent.rotation_degrees.z
	var powerPercentage = power * 100 / maxPower
	var impulseX = cos(deg_to_rad(angle)) * (powerPercentage / 100) * powerFacotr;
	var impulseY = sin(deg_to_rad(angle)) * (powerPercentage / 100) * powerFacotr;
	apply_central_impulse(Vector3(-impulseX, impulseY, 0))
	#material_override.albedo_color = Color.RED
	print('SHOOT => angle: ' + str(angle) + ', power: ' + str(powerPercentage))
	power = 0
	powerBarV2.value = 0

func _on_death_area_body_entered(body):
	position = respawnPosition
	linear_velocity = Vector3(0, 0, 0)
	angular_velocity = Vector3(0, 0, 0)
