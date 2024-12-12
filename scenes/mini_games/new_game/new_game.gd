extends Control

# Variables for the quiz
var current_question_index = 0
var json = JSON.new()
var score = 0
var required_score = 3  # Minimum score to pass
var questions = [] # Minimum score to pass
@onready var exit_button: Button = $TextureRect/ExitButton
@onready var http_request: HTTPRequest = $HTTPRequest

# Variables for UI components
@onready var judge_texture = $TextureRect3
@onready var crowd_texture = $TextureRect2
@onready var button1 = $TextureRect/Button
@onready var button2 = $TextureRect/Button2
@onready var button3 = $TextureRect/Button3
@onready var buttons = [
	$TextureRect/Button,
	$TextureRect/Button2,
	$TextureRect/Button3,
]

# Dialogue and questions
var judge_dialogue = "Welcome to the court. Let's begin the session!"

func _ready():
	# Initial setup
	fetch_questions()
	initialize_ui()
	exit_button.visible = false

	# Connect buttons to a common handler with a dynamic index using bind
	for i in range(buttons.size()):
		# Binding the index to the button press event
		buttons[i].connect("pressed", Callable(self, "_on_button_pressed").bind(i))

	# Start with the judge's dialogue
	show_judge_dialogue()

func initialize_ui():
	judge_texture.visible = false
	crowd_texture.visible = false
	button1.visible = false
	button2.visible = false
	button3.visible = false

func show_judge_dialogue() -> void:
	judge_texture.visible = true
	judge_texture.get_child(0).text = judge_dialogue
	await get_tree().create_timer(2).timeout  # Wait for 2 seconds
	proceed_to_question()

func proceed_to_question() -> void:
	judge_texture.visible = false
	crowd_texture.visible = true
	show_question()

func show_question() -> void:
	# Load current question
	if questions.is_empty():
		return
		
	# Reset button colors
	for button in buttons:
		button.modulate = Color(1, 1, 1, 1)  # Reset to default white color
		button.disabled = false
	
	# Hide exit button
	exit_button.visible = false
	
	# Display the current question and set the text for the answer buttons
	var question = questions[current_question_index]
	crowd_texture.get_child(0).text = question["question"]
	for i in range(3):
		buttons[i].text = question["options"][i]
	button1.visible = true
	button2.visible = true
	button3.visible = true
	for button in buttons:
		button.modulate = Color(1, 1, 1, 1)  # Reset to default white color
		button.disabled = false
	
func _on_button_pressed(button_index: int) -> void:
	check_answer(button_index)

func check_answer(selected_index: int) -> void:
	var current_question = questions[current_question_index]
	if buttons[selected_index].text == current_question["answer"][0]:
		# Correct answer
		buttons[selected_index].modulate = Color(0, 1, 0)  # Green for correct answer
		score += 1
	else:
		# Incorrect answer
		buttons[selected_index].modulate = Color(1, 0, 0)  # Red for incorrect answer
		
		# Find and highlight the correct answer in green
		for i in range(buttons.size()):
			if buttons[i].text == current_question["answer"][0]:
				buttons[i].modulate = Color(0, 1, 0)
				break
	
	# Move to the next question after a brief delay
	await get_tree().create_timer(1).timeout
	next_question()

func next_question() -> void:
	# Move to the next question or end the quiz
	current_question_index += 1
	if current_question_index >= questions.size():
		check_game_complete()
	else:
		show_question()

func check_game_complete() -> void:
	exit_button.visible = true

	# Implement your game completion logic here
	if score >= required_score:
		print("Congratulations! You've passed the quiz!")
	else:
		print("Game over! You didn't pass the quiz.")
	# Optionally, show a summary or restart the game

func fetch_questions() -> void:
	var post_data = {"area": "ex", "test": "quiz_ex_1","collection":"quiz"}
	var headers = ["Content-Type: application/json"]
	var response = http_request.request(Api.game, headers, HTTPClient.METHOD_GET,
		JSON.stringify(post_data))
	if response != OK:
		print("An error occurred in the HTTP request.")
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		print("Success")
		var error = json.parse(body.get_string_from_utf8())
		if error == OK:
			var response_data = json.get_data()
			questions = response_data["data"]
			if not questions.is_empty():
				show_question()
			else:
				print("No questions received from the server")
	else:
		print("HTTP Request failed with response code: ", response_code)
