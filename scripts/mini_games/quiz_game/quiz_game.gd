extends Control

# Variables for the quiz
var current_question_index = 0
var score = 0
var required_score = 3  # Minimum score to pass
var questions = []  # Store fetched questions

@onready var http_request: HTTPRequest = $HTTPRequest
var json = JSON.new()

# Cached UI elements
@onready var question_label = $VideoStreamPlayer/RichTextLabel
@onready var buttons = [
	$VideoStreamPlayer/Button,
	$VideoStreamPlayer/Button2,
	$VideoStreamPlayer/Button3,
	$VideoStreamPlayer/Button4
]
@onready var exit_button = $VideoStreamPlayer/ExitButton

func _ready() -> void:
	# Initialize the quiz by displaying the first question
	fetch_questions()
	# Connect button signals
	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_button_pressed.bind(i))
	
	# Connect exit button and hide it initially
	exit_button.pressed.connect(_on_exit_pressed)
	exit_button.visible = false
	
	# Connect HTTP request completion signal
	http_request.request_completed.connect(_on_http_request_request_completed)

func fetch_questions() -> void:
	var post_data = {"area": "ex", "test": "quiz_ex_1"}
	var headers = ["Content-Type: application/json"]
	var response = http_request.request(Api.quiz_game, headers, HTTPClient.METHOD_GET,
		JSON.stringify(post_data))
	if response != OK:
		print("An error occurred in the HTTP request.")

func display_question() -> void:
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
	question_label.text = question["question"]
	
	# Set text for buttons using options array
	for i in range(4):
		buttons[i].text = question["options"][i]

func _on_button_pressed(selected_index: int) -> void:
	var question = questions[current_question_index]
	var correct_answer = question["answer"]
	
	# Disable all buttons after selection
	disable_buttons()
	
	# Check if the selected answer is correct
	if buttons[selected_index].text == correct_answer:
		# Correct answer
		buttons[selected_index].modulate = Color(0, 1, 0)  # Green for correct answer
		score += 1
	else:
		# Incorrect answer
		buttons[selected_index].modulate = Color(1, 0, 0)  # Red for incorrect answer
		
		# Find and highlight the correct answer in green
		for i in range(buttons.size()):
			if buttons[i].text == correct_answer:
				buttons[i].modulate = Color(0, 1, 0)
				break
	
	# Move to the next question after a brief delay
	await get_tree().create_timer(1).timeout
	next_question()

func disable_buttons() -> void:
	# Disable all buttons after an answer is selected
	for button in buttons:
		button.disabled = true

func next_question() -> void:
	# Move to the next question or end the quiz
	current_question_index += 1
	if current_question_index >= questions.size():
		check_game_complete()
	else:
		display_question()

func check_game_complete() -> void:
	# Display the result of the quiz
	if score >= required_score:
		question_label.text = "Congratulations! You passed the quiz!\nScore: %d/%d" % [score, questions.size()]
		
		# Hide answer buttons
		for button in buttons:
			button.visible = false
		
		# Show exit button
		exit_button.visible = true
	else:
		question_label.text = "Game over! You need at least %d correct answers to pass.\nYour score: %d/%d" % [required_score, score, questions.size()]

func _on_exit_pressed() -> void:
	# Exit the application when exit button is pressed
	get_tree().quit()

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var error = json.parse(body.get_string_from_utf8())
		if error == OK:
			var response_data = json.get_data()
			questions = response_data["data"]
			if not questions.is_empty():
				display_question()
			else:
				print("No questions received from the server")
	else:
		print("HTTP Request failed with response code: ", response_code)
