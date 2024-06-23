extends Control

@onready var skinsContainer: GridContainer = $Panel/TabContainer/Skins/GridContainer

var buttonGroup := ButtonGroup.new()

var skins = {
	StateManagement.SkinTypes.lava: {
		'name': 'lava',
		'value': 'LAVA'
	},
	StateManagement.SkinTypes.golf: {
		'name': 'golf',
		'value': 'GOLF'
	},
}


func _ready() -> void:
	var skinSelected = StateManagement.userData.skin
	var index = 0
	var vBoxContainer: HBoxContainer
	for skinId in skins:
		if index % 4 == 0:
			vBoxContainer = HBoxContainer.new()
			vBoxContainer.theme = preload('res://resources/UiTheme.tres')
			skinsContainer.add_child(vBoxContainer)
		var newButton = Button.new()
		# newButton.button_group
		newButton.text = skins[skinId].name
		newButton.toggle_mode = true
		newButton.name = str(skinId)
		newButton.button_group = buttonGroup
		newButton.connect('pressed', buttonPressed.bind(skinId))
		if skinId == skinSelected:
			newButton.button_pressed = true
			newButton.call_deferred('grab_focus')
		vBoxContainer.add_child(newButton)
		index += 1
		
func buttonPressed(skinId) -> void:
	var collectionKey = 'users'
	var documentKey = StateManagement.authData.localid
	var collection: FirestoreCollection = Firebase.Firestore.collection(collectionKey)
	var fields = Utilities.dict2fields({ 'skin': str(skinId) }).fields
	var dataToSend = {
		'createTime': '', 
		'name': documentKey, 
		'fields': fields
	}
	collection.update(FirestoreDocument.new(dataToSend))
	StateManagement.userData.skin = skinId
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file('res://scenes/MainMenu.tscn')
