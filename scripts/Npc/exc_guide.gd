extends Node2D

var balloon_scene = preload("res://dialogues/game_balloon.tscn")
@onready var interactable_label_component: Control = $InteractableLabelComponent
@onready var interablecomponent: InteractableComponent = $interablecomponent

var http_request: HTTPRequest
var translation_request: HTTPRequest

const GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"
const API_KEY = "AIzaSyD1h8zNaWMAVk5VMDkyNZL2ByCaJwOGX9Y"

var json_parser = JSON.new()
var in_range: bool
var target_language: String = Language.language

# Fallback dialogue in case of server error
var FALLBACK_DIALOGUE = """~ start
Aadeshak: Hello, Rishi. I am Aadeshak, the Guardian of Admin Arena—the zone of action and governance.
Rishi: This place looks really busy! What happens here?
Aadeshak: Ah, yes! Admin Arena is where the Executive takes charge. From the President to Governors, they ensure that 
Aadeshak: laws are implemented and everything runs smoothly across the country. They are the ones who take action, making sure decisions made in Law Junction are carried out in the real world.
Rishi: So, it’s all about leadership and executing plans?
Aadeshak: Exactly! Whether it’s policies, government programs, or the everyday running of our nation, it all happens here. It’s a place of immense responsibility, where decisions impact millions.
Rishi: How can I learn more about governance and decision-making here?
Aadeshak: In Admin Arena, observe the leaders in action. Watch how decisions are made, how plans are turned into reality, 
Aadeshak: and how leaders ensure that the people’s needs are met. It’s a world of power, responsibility, and governance!
=> END"""

func _ready() -> void:
	# Create HTTPRequest nodes using call_deferred to ensure thread safety
	call_deferred("setup_http_requests")
	call_deferred("setup_interactable_connections")
	
	interactable_label_component.hide()
	
	# Ensure dialogue directory exists
	ensure_dialogue_directory()
	
	# Start fetching dialogue and translation 
	call_deferred("fetch_dialogue")
	
	print("Script initialized and ready")

func setup_http_requests() -> void:
	# Create HTTPRequest nodes if they don't exist
	if not has_node("HTTPRequest"):
		http_request = HTTPRequest.new()
		http_request.name = "HTTPRequest"
		add_child(http_request)
	else:
		http_request = $HTTPRequest
	
	if not has_node("TranslationRequest"):
		translation_request = HTTPRequest.new()
		translation_request.name = "TranslationRequest"
		add_child(translation_request)
	else:
		translation_request = $TranslationRequest
	
	# Setup HTTP request connections
	http_request.request_completed.connect(on_http_request_request_completed)
	translation_request.request_completed.connect(on_translation_request_completed)

func setup_interactable_connections() -> void:
	# Setup interactable component connections
	interablecomponent.interactable_activated.connect(on_interactable_activated)
	interablecomponent.interactable_deactivated.connect(on_interactable_deactivated)

func ensure_dialogue_directory() -> void:
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("dialogues/conversations"):
		dir.make_dir_recursive("dialogues/conversations")

func on_interactable_activated() -> void:
	print("Interactable activated")
	# Use call_deferred to ensure UI updates happen on main thread
	interactable_label_component.call_deferred("show")
	in_range = true

func on_interactable_deactivated() -> void:
	# Use call_deferred to ensure UI updates happen on main thread
	interactable_label_component.call_deferred("hide")
	in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if in_range and event.is_action_pressed("interact"):
		trigger_dialogue_on_start()

func fetch_dialogue() -> void:
	print("Attempting to fetch dialogue from: https://flaskserver-rho.vercel.app/dialogue")
	var headers = ["Content-Type: application/json"]
	var error = http_request.request("https://flaskserver-rho.vercel.app/dialogue", headers, HTTPClient.METHOD_GET)
	if error != OK:
		print("An error occurred in the HTTP request: ", error)
		call_deferred("use_fallback_dialogue")

func on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("HTTP Request completed. Response code: ", response_code)
	
	if response_code != 200:
		print("Server error. Using fallback dialogue.")
		call_deferred("use_fallback_dialogue")
		return

	var response_string = body.get_string_from_utf8()
	print("Full Response Body: ", response_string)
	
	# Attempt to parse the response
	var error = json_parser.parse(response_string)
	if error == OK:
		var dialogue_data = json_parser.get_data()
		print("Parsed Dialogue Data: ", dialogue_data)
		
		# Construct dialogue string for translation
		var dialogue_to_translate = ""
		
		if dialogue_data.has("dialogues"):
			for dialogue in dialogue_data.dialogues:
				dialogue_to_translate += dialogue.character + ": " + dialogue.text + "\n"
			
			print("Dialogue to Translate: ", dialogue_to_translate)
			call_deferred("translate_dialogue", dialogue_to_translate)
		else:
			print("Unexpected dialogue data structure")
			print("Available keys: ", dialogue_data.keys())
			call_deferred("use_fallback_dialogue")
	else:
		print("JSON parsing error: ", json_parser.error_message)
		call_deferred("use_fallback_dialogue")

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
	print("Translation request completed. Response code: ", response_code)
	
	if response_code == 200:
		var response_string = body.get_string_from_utf8()
		print("Translation Response: ", response_string)
		
		var parse_result = json_parser.parse(response_string)
		
		if parse_result == OK:
			var json_response = json_parser.get_data()
			
			if json_response.has("candidates") and json_response["candidates"].size() > 0:
				var translated_text = json_response["candidates"][0]["content"]["parts"][0]["text"]
				print("Translated Text: ", translated_text)
				
				var dialogue_path = "res://dialogues/conversations/executive_translated.dialogue"
				ensure_dialogue_directory()
				
				# Create dialogue file with translated content
				var dialogue_file_content = "~ start\n" + translated_text + "\n=> END"
				
				# Write new file using call_deferred to ensure thread safety
				call_deferred("write_dialogue_file", dialogue_path, dialogue_file_content)
			else:
				print("Error: Translation result not found in response")
		else:
			print("Error parsing JSON: ", json_parser.error_message)
	else:
		print("Translation request failed with response code: ", response_code)

func write_dialogue_file(dialogue_path: String, content: String) -> void:
	var file = FileAccess.open(dialogue_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("Translated dialogue file created successfully at: ", dialogue_path)
	else:
		print("Error: Could not create translated dialogue file")

func use_fallback_dialogue() -> void:
	print("Using fallback dialogue")
	
	var dialogue_path = "res://dialogues/conversations/executive.dialogue"
	ensure_dialogue_directory()
	
	# Write fallback dialogue file
	var file = FileAccess.open(dialogue_path, FileAccess.WRITE)
	if file:
		file.store_string(FALLBACK_DIALOGUE)
		file.close()
		print("Fallback dialogue written to: ", dialogue_path)
		call_deferred("translate_dialogue", FALLBACK_DIALOGUE)
	else:
		print("ERROR: Could not create fallback dialogue file")

func trigger_dialogue_on_start() -> void:
	print("Triggering dialogue")
	
	# Try loading dialogue files
	var dialogue_path = "res://dialogues/conversations/executive"
	var translated_file = load(dialogue_path + "_translated.dialogue")
	var original_file = load(dialogue_path + ".dialogue")
	
	# If no files exist at all, use fallback
	if not original_file:
		print("ERROR: No original dialogue file found")
		call_deferred("use_fallback_dialogue")
		return
	
	# If translation is not ready, start a translation process
	if not translated_file:
		print("Translation not found, initiating translation")
		
		# Fetch or use fallback dialogue
		call_deferred("fetch_dialogue")
		
		# Use a signal-based approach instead of blocking
		await get_tree().create_timer(3.0).timeout
		
		# Reload translated file
		translated_file = load(dialogue_path + "_translated.dialogue")
		
		# If translation still not ready, fall back to original
		if not translated_file:
			print("Translation still not ready after waiting")
	
	# Instantiate balloon using call_deferred
	call_deferred("start_dialogue_balloon", translated_file, original_file)

func start_dialogue_balloon(translated_file: Resource, original_file: Resource) -> void:
	# Instantiate balloon
	var balloon = balloon_scene.instantiate() as BaseGameDialogueBalloon
	if not balloon:
		print("ERROR: Could not instantiate balloon scene")
		return
	
	get_tree().root.add_child(balloon)
	
	# Choose dialogue file
	if translated_file:
		print("Starting dialogue with translated file")
		balloon.start(translated_file, "start")
	else:
		print("Starting dialogue with original file")
		balloon.start(original_file, "start")
