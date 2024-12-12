extends Node2D

var balloon_scene = preload("res://dialogues/game_balloon.tscn")
@onready var interactable_label_component: Control = $InteractableLabelComponent
@onready var interablecomponent: InteractableComponent = $interablecomponent
@onready var http_request: HTTPRequest = $HTTPRequest

var translation_request: HTTPRequest
var in_range: bool
var json_parser = JSON.new()
var target_language: String = "Hindi"

const GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"
const API_KEY = "AIzaSyD1h8zNaWMAVk5VMDkyNZL2ByCaJwOGX9Y"

func _ready() -> void:
	# Create translation request node
	if not has_node("TranslationRequest"):
		translation_request = HTTPRequest.new()
		translation_request.name = "TranslationRequest"
		add_child(translation_request)
	else:
		translation_request = $TranslationRequest
	
	interablecomponent.interactable_activated.connect(on_interactable_activated)
	interablecomponent.interactable_deactivated.connect(on_interactable_deactivated)
	
	http_request.request_completed.connect(on_http_request_request_completed)
	translation_request.request_completed.connect(on_translation_request_completed)
	
	interactable_label_component.hide()

func on_interactable_activated() -> void:
	interactable_label_component.show()
	in_range = true
	fetch_dialogue()

func on_interactable_deactivated() -> void:
	interactable_label_component.hide()
	in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if in_range:
		if event.is_action_pressed("interact"):
			trigger_dialogue_on_start()

func fetch_dialogue():
	var post_data = {"area": "base_map"}
	var headers = ["Content-Type: application/json"]
	var response = http_request.request(
		Api.dialogue,
		headers,
		HTTPClient.METHOD_GET,
		JSON.stringify(post_data)
	)
	if response != OK:
		print("An error occurred in the HTTP request.")

func on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		print("Success")
		var error = json_parser.parse(body.get_string_from_utf8())
		if error == OK:
			var dialogue_data = json_parser.get_data()
			
			# Prepare dialogue for translation
			var dialogue_to_translate = ""
			for dialogue in dialogue_data.base_map.npc_1:
				dialogue_to_translate += dialogue.character + ": " + dialogue.dialogue + "\n"
			
			# Start translation process
			translate_dialogue(dialogue_to_translate)
			
			# Trigger original dialogue immediately
			trigger_dialogue_on_start()
	else:
		print(response_code)

func translate_dialogue(dialogue_to_translate: String) -> void:
	print("Starting translation of dialogue")
	var body = {
		"contents": [
			{
				"parts": [
					{
						"text": "Translate the following dialogue to " + target_language + ".\n"
								+ "Important rules:\n"
								+ "1. Do NOT translate the names of the speakers.\n"
								+ "2. Preserve the exact dialogue structure (Person A: ... \\nPerson B: ...).\n"
								+ "3. Translate only the dialogue text.\n"
								+ "4. Maintain the original tone and context.\n"
								+ "Original Dialogue: " + dialogue_to_translate
					}
				]
			}
		],
	}
	
	var headers = ["Content-Type: application/json"]
	var url = GEMINI_API_URL + "?key=" + API_KEY
	var error = translation_request.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)
	if error != OK:
		print("Error initiating translation request: ", error)

func on_translation_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var response_string = body.get_string_from_utf8()
		var parse_result = json_parser.parse(response_string)
		
		if parse_result == OK:
			var json_response = json_parser.get_data()
			
			if json_response.has("candidates") and json_response["candidates"].size() > 0:
				var translated_text = json_response["candidates"][0]["content"]["parts"][0]["text"]
				print("Translation received: ", translated_text)
				# Here you could emit a signal with the translated text
				# or store it in a variable to be used later
			else:
				print("Error: Translation result not found in response")
		else:
			print("Error parsing JSON response")
	else:
		print("Translation request failed with response code: ", response_code)

func trigger_dialogue_on_start() -> void:
	var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
	get_tree().root.add_child(balloon)
	balloon.start(load("res://dialogues/conversations/legislative.dialogue"), "start")
