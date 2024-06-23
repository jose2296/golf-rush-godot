extends Node3D

func _ready() -> void:
	var mapScene = preload('res://prefabs/Maps/Map1.tscn')
	var basicMap = preload('res://scenes/BasicMap.tscn')
	var playerScene = preload('res://prefabs/Player/Player.tscn')
	var player = playerScene.instantiate()
	if StateManagement.userData:
		player.controlType = StateManagement.userData.controlType
		player.skin = StateManagement.userData.skin
		player.trail = StateManagement.userData.trail
		player.accessory = StateManagement.userData.accessory
	add_child(basicMap.instantiate())
	add_child(mapScene.instantiate())
	add_child(player)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/MainMenu.tscn')
