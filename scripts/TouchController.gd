extends Control

@onready var player: Player = $".."
@export var offset = 100
@export var defaultLineColor = Color.BLUE
@onready var powerBar: PowerBar = $"../PowerBar"
@onready var directionBar: Node3D = $"../DirectionBarParent"
var lineColor = defaultLineColor

var startPoint: Vector2 = Vector2(0, 0)
var destinationPoint: Vector2 = Vector2(0, 0)

var isDragging = false
var isTouching = false

func _physics_process(delta):
	if player.sleeping and isTouching:
		player.handlePressShoot(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent):
	if !player.sleeping:
		return
			
	if (event is InputEventScreenTouch):
		if event.pressed:
			startPoint = event.position
			isTouching = true
		else:
			isTouching = false
			queue_redraw()
			reset()
			player.shoot()
				
	if (event is InputEventScreenDrag):
		isDragging = true
		destinationPoint = event.position
		var angle2 = atan2(destinationPoint.y - startPoint.y, destinationPoint.x - startPoint.x)
		var angle = abs(angle2 * (180 / PI) - 180)
		directionBar.rotation_degrees.z = angle
		queue_redraw()
		
func reset():
	startPoint = Vector2(0, 0)
	destinationPoint = Vector2(0, 0)
	isDragging = false
	lineColor = defaultLineColor
		
func _draw():
	draw_line(startPoint, destinationPoint, lineColor)
	
