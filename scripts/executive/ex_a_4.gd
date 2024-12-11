extends Node2D

@onready var reading_material: CanvasLayer = $script
@onready var text: RichTextLabel = $script/RichTextLabel
@onready var http_request: HTTPRequest = $HTTPRequest  # Assuming you have an HTTPRequest node

# Variables to store retrieved data
var chest_content = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	request_chest_data()
	# Initially hide the reading material
	reading_material.hide()
	print("started")
	# Ensure HTTPRequest node is configured
	if http_request:
		# Connect the request completed signal
		http_request.connect("request_completed", Callable(self, "_on_chest_1_request_completed"))

# Function to request data from the database
func request_chest_data() -> void:
	# Replace with your actual database endpoint
	
	
	# Prepare headers if needed
	var headers = PackedStringArray([
		"Content-Type: application/json"
		# Add any authentication headers here
	])
	var post_data = {"area":"ex","map":"ex_a1"}
	# Send the HTTP request
	var response = http_request.request(Api.read, headers, HTTPClient.METHOD_GET,JSON.stringify(post_data))
	if response != OK:
		print("An error occurred while fetching chest data.")

# Parse the retrieved JSON data	

# Function to format the text for display	

	

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	# Check if the request was successful
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		print("Success")
		# Parse the JSON response
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		
		if parse_result == OK:
			# Store the retrieved data
			chest_content = json.get_data()
			print("Chest data retrieved successfully")
			print(chest_content)
			
			# Directly format and set the text for reading_material_1
			if chest_content != null and "ex_a1" in chest_content and "reading_material_1" in chest_content["ex_a1"]:
				var formatted_text = ""
				var materials = chest_content["ex_a1"]["reading_material_1"]
				
				for material in materials:
					formatted_text += "Article %d: %s\n\n" % [
						material["article_number"], 
						material["summary"]
					]
				text.text = formatted_text
		else:
			print("Error parsing JSON: ", json.get_error_message())
	else:
		print("HTTP Request failed with response code: ", response_code)


func _on_area_2d_body_entered(body: Node2D) -> void:
	# If data hasn't been retrieved yet, request it
	print("interacted")
	# Display the reading material
	reading_material.show()
	
	# If chest_content is already available, update the text


func _on_assesment_1_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scenes/mini_games/quiz_game/quiz_game.tscn")
