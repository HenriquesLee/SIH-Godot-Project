extends Node2D

var balloon_scene = preload("res://dialogues/game_balloon.tscn")
@onready var http_request: HTTPRequest = $HTTPRequest
var json_parser = JSON.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Controls.show()
	$CanvasLayer/Fade_transition.show()
	$CanvasLayer/Fade_transition/AnimationPlayer.play("Fade_out")
	fetch_dialogue()
func fetch_dialogue():
	var post_data = {"area":"base_map"}
	var headers = ["Content-Type: application/json"]
	var response = http_request.request("https://sih-api-1efm.onrender.com/dialogue",headers,HTTPClient.METHOD_GET,
	JSON.stringify(post_data))
	if response != OK:
		print("An error occurred in the HTTP request.")
		
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		print("Success")
		var error = json_parser.parse(body.get_string_from_utf8())
		if error == OK:
			var dialogue_data = json_parser.get_data()
			# Remove existing file if it exists
			if FileAccess.file_exists("res://dialogues/coversations/start.dialogue"):
				DirAccess.remove_absolute("res://dialogues/coversations/start.dialogue")
			
			# Create dialogue file content
			var dialogue_file_content = "~ start\n"
			
			# Add dialogues from JSON
			for dialogue in dialogue_data.base_map.guard:
				dialogue_file_content += dialogue.character + ": " + dialogue.dialogue + "\n"
				
			dialogue_file_content += "=> END\n"
			
			# Write new file
			var file = FileAccess.open("res://dialogues/coversations/start.dialogue", FileAccess.WRITE)
			file.store_string(dialogue_file_content)
			file.close()
			
			trigger_dialogue_on_start()
	else:
		print(response_code)

func trigger_dialogue_on_start() -> void:
	var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
	get_tree().root.add_child(balloon)  # Add to the scene tree
	balloon.start(load("res://dialogues/coversations/start.dialogue"), "start")
