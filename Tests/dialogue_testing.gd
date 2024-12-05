extends Node2D
var json_parser = JSON.new()
var http_request = HTTPRequest.new()
var balloon_scene = preload("res://dialogues/game_balloon.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(http_request)
	fetch_dialogue()
	trigger_dialogue_on_start()

func fetch_dialogue():
	var url = "http://localhost:5000/get-dialogue"
	var error = http_request.request(url)
	if error != OK:
		print("An error occurred in the HTTP request.")

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var error = json_parser.parse(body.get_string_from_utf8())
		if error == OK:
			var dialogue_data = json_parser.get_data()
			
			# Just get the first dialogue and update global variables
			if dialogue_data.dialogue.size() > 0:
				Dialogues.character_name = dialogue_data.dialogue[0].character
				Dialogues.dialogue = dialogue_data.dialogue[0].text

func trigger_dialogue_on_start() -> void:
	var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
	get_tree().root.add_child(balloon)  # Add to the scene tree
	balloon.start(load("res://dialogues/coversations/self.dialogue"), "Chinu")
