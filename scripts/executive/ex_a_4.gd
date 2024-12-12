extends Node2D

@onready var reading_material: CanvasLayer = $script
@onready var text: RichTextLabel = $script/RichTextLabel
@onready var http_request: HTTPRequest = $HTTPRequest  # Assuming you have an HTTPRequest node
var formatted_text = ""
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
		else:
			print("Error parsing JSON: ", json.get_error_message())
	else:
		print("HTTP Request failed with response code: ", response_code)

func format_material_text(materials: Array) -> String:
	var formatted_text = ""
	for material in materials:
		formatted_text += "Article %d: %s\n\n" % [
			material["article_number"], 
			material["summary"]
		]
	return formatted_text

func _on_chest_1_body_entered(body: Node2D) -> void:
	print("interacted")
	if chest_content != null and "ex_a1" in chest_content and "reading_material_1" in chest_content["ex_a1"]:
		var materials = chest_content["ex_a1"]["reading_material_1"]
		var formatted_text = format_material_text(materials)
		text.text = formatted_text
		reading_material.show()
	else:
		text.text = "No content found"
		reading_material.show()
	print(text.text)
	# If chest_content is already available, update the text


func _on_assesment_1_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scenes/mini_games/quiz_game/quiz_game.tscn")


func _on_chest_2_body_entered(body: Node2D) -> void:
	# Check if chest_content is available
	if chest_content != null and "ex_a1" in chest_content and "reading_material_2" in chest_content["ex_a1"]:
		var materials = chest_content["ex_a1"]["reading_material_2"]
		
		# Format the text for reading material 2
		var formatted_text = ""
		for material in materials:
			formatted_text += "Article %d: %s\n\n" % [
				material["article_number"], 
				material["summary"]
			]
		
		# Set the text and show the reading material
		text.text = formatted_text
		reading_material.show()


func _on_chest_3_body_entered(body: Node2D) -> void:
	# Check if chest_content is available
	if chest_content != null and "ex_a1" in chest_content and "reading_material_3" in chest_content["ex_a1"]:
		var materials = chest_content["ex_a1"]["reading_material_3"]
		
		# Format the text for reading material 3
		var formatted_text = ""
		for material in materials:
			formatted_text += "Article %d: %s\n\n" % [
				material["article_number"], 
				material["summary"]
			]
		
		# Set the text and show the reading material
		text.text = formatted_text
		reading_material.show()




func _on_chest_4_body_entered(body: Node2D) -> void:
	# Check if chest_content is available
	if chest_content != null and "ex_a1" in chest_content and "reading_material_3" in chest_content["ex_a1"]:
		var materials = chest_content["ex_a1"]["reading_material_4"]
		
		# Format the text for reading material 3
		var formatted_text = ""
		for material in materials:
			formatted_text += "Article %d: %s\n\n" % [
				material["article_number"], 
				material["summary"]
			]
		
		# Set the text and show the reading material
		text.text = formatted_text
		reading_material.show()


func _on_chest_5_body_entered(body: Node2D) -> void:
	# Check if chest_content is available
	if chest_content != null and "ex_a1" in chest_content and "reading_material_3" in chest_content["ex_a1"]:
		var materials = chest_content["ex_a1"]["reading_material_5"]
		
		# Format the text for reading material 3
		var formatted_text = ""
		for material in materials:
			formatted_text += "Article %d: %s\n\n" % [
				material["article_number"], 
				material["summary"]
			]
		
		# Set the text and show the reading material
		text.text = formatted_text
		reading_material.show()


func _on_chest_6_body_entered(body: Node2D) -> void:
	# Check if chest_content is available
	if chest_content != null and "ex_a1" in chest_content and "reading_material_3" in chest_content["ex_a1"]:
		var materials = chest_content["ex_a1"]["reading_material_6"]
		
		# Format the text for reading material 3
		var formatted_text = ""
		for material in materials:
			formatted_text += "Article %d: %s\n\n" % [
				material["article_number"], 
				material["summary"]
			]
		
		# Set the text and show the reading material
		text.text = formatted_text
		reading_material.show()
