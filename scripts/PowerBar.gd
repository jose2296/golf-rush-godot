class_name PowerBar extends MeshInstance3D

@onready var powerBarValue = $Value
var powerBarMaxScaleX = 0.95
var powerBarMinPositionX = -0.48

func updateValue(powerPercentage: float):
	var powerBarScaleX = powerBarMaxScaleX * powerPercentage / 100
	var positionX = (powerPercentage * powerBarMinPositionX / 100) * -1
	powerBarValue.scale.x = powerBarScaleX
	powerBarValue.position.x = powerBarMinPositionX + positionX
