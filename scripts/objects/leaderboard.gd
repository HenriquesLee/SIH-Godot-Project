extends Control

@onready var label = $Label  # Assuming you have a Label node to display the leaderboard

func _ready():
	# Debug check for label
	if label:
		print("Label found: ", label.name)
	else:
		print("ERROR: Label not found! Check your scene structure.")
	
	fetch_leaderboard_data()

func fetch_leaderboard_data():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_leaderboard_request_completed)
	
	var error = http_request.request("https://flaskserver-rho.vercel.app/leaderboard")
	if error != OK:
		print("An error occurred while fetching leaderboard data.")
		# Optionally, show an error message on the label
		if label:
			label.text = "Error: Could not fetch leaderboard"

func _on_leaderboard_request_completed(result, response_code, headers, body):
	print("Request completed with result: ", result)
	print("Response code: ", response_code)
	
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Leaderboard request failed with result: ", result)
		# Update label with error message if possible
		if label:
			label.text = "Error: Leaderboard request failed"
		return
	
	# Ensure we can parse the JSON
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		print("Failed to parse leaderboard JSON")
		print("Body received: ", body.get_string_from_utf8())  # Log the raw body for debugging
		
		# Update label with parsing error
		if label:
			label.text = "Error: Could not parse leaderboard data"
		return
	
	var data = json.get_data()
	print("Data received: ", data)  # Log the parsed data
	
	# Safely access the leaderboard array
	var leaderboard_data = data.get("leaderboard", [])
	print("Leaderboard data received: ", leaderboard_data)  # Log the leaderboard data
	
	# Check if leaderboard_data is an array
	if not leaderboard_data is Array:
		print("Leaderboard data is not an array. Data type: ", typeof(leaderboard_data))
		
		# Update label with type error
		if label:
			label.text = "Error: Invalid leaderboard data"
		return
	
	# Sort the leaderboard data by score in descending order
	leaderboard_data.sort_custom(func(a, b): 
		return b.get("score", 0) > a.get("score", 0)
	)
	
	# Prepare the display string for the top 10 entries
	var display_text = "Top 10 Leaderboard:\n"
	for index in range(min(10, leaderboard_data.size())):
		var entry = leaderboard_data[index]
		var username = entry.get("username", "Unknown")
		var score = entry.get("score", 0)
		display_text += str(index + 1) + ". " + username + ": " + str(score) + "\n"
	
	# Set the text of the label to display the leaderboard
	if label:
		label.text = display_text
		print("Display text set to label: ", display_text)
	else:
		print("ERROR: Cannot set label text - label is null")


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/others/base map.tscn") # Replace with function body.
