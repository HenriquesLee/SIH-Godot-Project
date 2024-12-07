extends Control

@onready var line_edit: LineEdit = $TextureRect/LineEdit
@onready var line_edit_2: LineEdit = $TextureRect/LineEdit2
@onready var submit: TextureButton = $TextureRect/Submit
@onready var rich_text_label_4: RichTextLabel = $TextureRect/RichTextLabel4
@onready var http_request: HTTPRequest = $HTTPRequest

func _ready() -> void:
	rich_text_label_4.hide()

func _process(delta: float) -> void:
	pass

func _on_texture_button_pressed() -> void:
	var username = line_edit.text.strip_edges()
	var age: String = line_edit_2.text.strip_edges()
	
	if username.is_empty() or age.is_empty():
		show_error("Please fill all fields")
		return
		
	if not is_valid_username(username):
		show_error("Username must contain only letters or underscores")
		return
		
	if not is_valid_age(age):
		show_error("Age must be a valid integer")
		return

	var post_data = {"username": username, "age": int(age)}
	var headers = ["Content-Type: application/json"]
	
	http_request.request("https://sih-api-1efm.onrender.com/insert",headers,
	HTTPClient.METHOD_POST,
	JSON.stringify(post_data))
	
	line_edit.clear()
	line_edit_2.clear()

func show_error(message: String) -> void:
	rich_text_label_4.clear()
	rich_text_label_4.add_text(message)
	rich_text_label_4.show()

func is_valid_username(username: String) -> bool:
	return username.is_valid_identifier()

func is_valid_age(age: String) -> bool:
	return age.is_valid_hex_number()

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 201:
		var json = JSON.parse_string(body.get_string_from_utf8())
		UserData.UserId = json["userid"]
		print(UserData.UserId)
	else:
		print("Failed with code: ", response_code)
