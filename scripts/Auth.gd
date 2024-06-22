extends Control

@onready var form = $Form
@onready var loading = $Loading

# Called when the node enters the scene tree for the first time.
func _ready():
	loading.visible = true
	Firebase.Auth.login_succeeded.connect(_on_FirebaseAuth_login_succeeded)
	Firebase.Auth.signup_succeeded.connect(_on_FirebaseAuth_login_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_failed.connect(on_signup_failed)
	if Firebase.Auth.check_auth_file():
		print('Logged, loading main menu')
	else:
		form.visible = true
		loading.visible = false
	# Firebase.Auth.login_with_email_and_password(email, password)

func _on_login_pressed():
	#var email = $email.text
	#var password = $password.text
	
	var email = 'josejerez2296@gmail.com'
	var password = 'secret'
	loading.visible = true
	form.visible = false
	Firebase.Auth.login_with_email_and_password(email, password)

func _on_register_pressed():
	var email = $email.text
	var password = $password.text
	Firebase.Auth.signup_with_email_and_password(email, password)

func _on_FirebaseAuth_login_succeeded(auth):
	print(auth)
	Firebase.Auth.save_auth(auth)
	form.visible = false
	loading.visible = false
	get_tree().change_scene_to_file('res://scenes/MainMenu.tscn')
	
func on_login_failed(error_code, message):
	print("error code: " + str(error_code))
	print("message: " + str(message))

func on_signup_failed(error_code, message):
	print("error code: " + str(error_code))
	print("message: " + str(message))

