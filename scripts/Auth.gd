extends Control

@onready var forms = $Forms
@onready var loading = $Loading
const collectionKey = 'users'
# Called when the node enters the scene tree for the first time.
func _ready():
	loading.visible = true
	Firebase.Auth.login_succeeded.connect(_on_FirebaseAuth_login_succeeded)
	Firebase.Auth.signup_succeeded.connect(_on_FirebaseAuth_signup_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_failed.connect(on_signup_failed)
	if !Firebase.Auth.check_auth_file():
		forms.visible = true
		loading.visible = false
	# Firebase.Auth.login_with_email_and_password(email, password)

func _on_login_pressed():
	var email = $Forms/LoginForm/Email.text
	var password = $Forms/LoginForm/Password.text
	
	#var email = 'josejerez2296@gmail.com'
	#var password = 'secret'
	loading.visible = true
	forms.visible = false
	Firebase.Auth.login_with_email_and_password(email, password)

func _on_register_pressed():
	var email = $Forms/RegisterForm/Email.text
	var password = $Forms/RegisterForm/Password.text
	loading.visible = true
	forms.visible = false
	Firebase.Auth.signup_with_email_and_password(email, password)

func _on_FirebaseAuth_login_succeeded(auth):
	Firebase.Auth.save_auth(auth)
	StateManagement.authData = auth
	var collection: FirestoreCollection = Firebase.Firestore.collection(collectionKey)
	var data: FirestoreDocument = await collection.get_doc(auth.localid)
	var parsedData = Utilities.fields2dict({ 'fields': data.document })
	StateManagement.userData = StateManagement.UserData.new(parsedData)
	forms.visible = false
	loading.visible = false
	get_tree().change_scene_to_file('res://scenes/MainMenu.tscn')
	
func _on_FirebaseAuth_signup_succeeded(auth):
	var collection: FirestoreCollection = Firebase.Firestore.collection(collectionKey)
	var controlType = StateManagement.ControlTypes.keyboard
	if OS.get_model_name() != 'GenericDevice':
		controlType = StateManagement.ControlTypes.touch
	var fields = Utilities.dict2fields({ 
		'nickName': auth.localid,
		'skin': StateManagement.SkinTypes.lava,
		'trail': StateManagement.TrailTypes.none,
		'accessory': StateManagement.AccessoryTypes.none,
		'controlType': controlType
	}).fields
	var dataToSend = {
		'createTime': '', 
		'name': auth.localid, 
		'fields': fields
	}
	collection.update(FirestoreDocument.new(dataToSend))
	_on_FirebaseAuth_login_succeeded(auth)

func on_login_failed(error_code, message):
	print("error code: " + str(error_code))
	print("message: " + str(message))
	loading.visible = false
	forms.visible = true
	$Forms/LoginForm/ErrorMessage.text = message

func on_signup_failed(error_code, message):
	print("error code: " + str(error_code))
	print("message: " + str(message))
	loading.visible = false
	forms.visible = true
	
	$Forms/RegisterForm/ErrorMessage.text = message
func _on_login_link_pressed() -> void:
	$Forms/RegisterForm.visible = false
	$Forms/LoginForm.visible = true

func _on_register_link_pressed() -> void:
	$Forms/RegisterForm.visible = true
	$Forms/LoginForm.visible = false
