extends Node

var userLoaded = false
var userData := UserData.new()
var authData := {
	'localid': 'NPsMdOnlqFTdsQt3fpM6UAjt5OY2'
}

enum TrailTypes {
	none,
	basic
}

enum SkinTypes {
	lava,
	golf
}

enum AccessoryTypes {
	none,
	crown
}

enum ControlTypes {
	keyboard,
	touch,
	disabled
}

func _ready() -> void:
	if Firebase.Auth.check_auth_file():
		userLoaded = true
	
class UserData:
	var nickName: String = 'Test'
	var skin: SkinTypes = SkinTypes.lava
	var trail: TrailTypes = TrailTypes.basic
	var accessory: AccessoryTypes = AccessoryTypes.crown
	var controlType: ControlTypes = ControlTypes.keyboard
	
	var defaultData = {
		'nickName': 'Test',
		'skin': SkinTypes.lava,
		'trail': TrailTypes.basic,
		'accessory': AccessoryTypes.crown,
		'controlType': ControlTypes.keyboard
	}

	func _init(data: Dictionary = defaultData):
		nickName = data.nickName
		skin = int(data.skin)
		trail = int(data.trail)
		accessory = int(data.accessory)
		controlType = int(data.controlType)
		
		
