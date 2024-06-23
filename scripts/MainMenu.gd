extends Control

func _ready():
	if StateManagement.userData:
		$UserName.text = str(StateManagement.userData.nickName)
func _on_logout_pressed():
	Firebase.Auth.logout()
	get_tree().change_scene_to_file('res://scenes/Auth.tscn')

func _on_play_pressed():
	get_tree().change_scene_to_file('res://scenes/SceneMap1.tscn')

func _on_customize_pressed():
	get_tree().change_scene_to_file('res://scenes/Customize.tscn')

func _on_practice_pressed():
	get_tree().change_scene_to_file('res://scenes/Practice.tscn')
