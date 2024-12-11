extends Control

const GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"
const API_KEY = "AIzaSyD1h8zNaWMAVk5VMDkyNZL2ByCaJwOGX9Y"

@onready var ask_button = $Button
@onready var question_input = $question
@onready var chatbot_response = $answers
@onready var return_button = $ReturnButton

var http_request: HTTPRequest

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	ask_button.pressed.connect(_on_ask_button_pressed)
	
	# Connect return button
	if return_button:
		return_button.pressed.connect(return_to_previous_scene)
	else:
		print("Warning: Return Button not found in the scene!")
		
func _on_ask_button_pressed():
	var user_question = question_input.text.strip_edges()
	if user_question == "":
		chatbot_response.text = "Please enter a question."
		return
	
	var body = {
		"contents": [
			{
				"parts": [
					{
						"text": """You are a highly specialized chatbot focused on the Indian Constitution. Your task is to provide comprehensive answers about constitutional matters. Here are your guidelines:

1. For questions about constitutional offices (President, Prime Minister, etc.):
   - Always cite relevant Articles and constitutional provisions
   - Explain their constitutional roles and responsibilities
   - Include information about their position in the constitutional framework
   - Mention relevant constitutional relationships with other offices

2. For questions about constitutional concepts:
   - Provide clear explanations with relevant Article citations
   - Include any relevant amendments or interpretations
   - Explain the constitutional significance

3. For questions about government structure:
   - Explain the constitutional basis
   - Detail the relationships between different bodies
   - Cite relevant Articles and provisions

4. For completely unrelated questions:
   - Respond with "This query is not related to the Indian Constitution."

5. Format your responses with:
   - Clear headings for different aspects
   - Bullet points for key information
   - Article citations in parentheses
   - Constitutional significance explicitly stated

For questions about the Prime Minister, always include:
- Constitutional basis under Article 75
- Role as head of the Council of Ministers
- Constitutional responsibilities in advising the President
- Position as the leader of the Union Executive

Question: """ + user_question
					}
				]
			}
		],
		"generationConfig": {
			"temperature": 0.7,
			"maxOutputTokens": 2048
		}
	}
	
	var headers = ["Content-Type: application/json"]
	var url = GEMINI_API_URL + "?key=" + API_KEY
	
	var err = http_request.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)
	
	if err != OK:
		chatbot_response.text = "Error initiating request: " + str(err)

func return_to_previous_scene():
	# Get the top scene from the stack
	var previous_scene = SceneNavigationManager.pop_scene()
	
	if previous_scene and previous_scene != "":
		# Change to the previous scene
		get_tree().change_scene_to_file(previous_scene)
	else:
		print("No previous scene available!")
		# Fallback to a default scene if needed
		# get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# Modify your scene change methods to use SceneNavigationManager
func navigate_to_ai_scene():
	SceneNavigationManager.change_scene("res://scenes/others/AI.tscn")



func _on_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray):
	if response_code == 200:
		var response_string = body.get_string_from_utf8()
		var json_parser = JSON.new()
		var parse_result = json_parser.parse(response_string)
		
		if parse_result == OK:
			var json_response = json_parser.get_data()
			
			if json_response.has("candidates") and json_response["candidates"].size() > 0:
				var response_text = json_response["candidates"][0]["content"]["parts"][0]["text"]
				
				# Format the response for better readability
				response_text = response_text.replace("1.", "\n1.")
				response_text = response_text.replace("2.", "\n2.")
				response_text = response_text.replace("3.", "\n3.")
				response_text = response_text.replace("4.", "\n4.")
				
				chatbot_response.text = response_text
			else:
				chatbot_response.text = "Error: Response not found in API result."
		else:
			chatbot_response.text = "Error parsing JSON: " + json_parser.error_message
	else:
		chatbot_response.text = "Request failed with response code: " + str(response_code)
