extends Control

# Variables for the quiz
var current_question_index = 0
var score = 0
var required_score = 3  # Minimum score to pass
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
@onready var exit_button = $VideoStreamPlayer/ExitButton  # Add this line for the exit button

func _ready() -> void:
	# Initialize the quiz by displaying the first question
	fetch_questions()

	# Connect button signals
	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_button_pressed.bind(i))
	
	# Connect exit button and hide it initially
	exit_button.pressed.connect(_on_exit_pressed)
	exit_button.visible = false
func fetch_questions() -> void:
	var post_data = {"area":"ex","test":"quiz_ex_1"}
	var headers = ["Content-Type: application/json"]
	var response = http_request.request(Api.quiz_game,headers,HTTPClient.METHOD_GET,
	JSON.stringify(post_data))
	if response != OK:
		print("An error occurred in the HTTP request.")
	

func display_question(questions) -> void:
	# Reset button colors
	for button in buttons:
		button.modulate = Color(1, 1, 1, 1)  # Reset to default white color
		button.disabled = false
	
	# Hide exit button
	exit_button.visible = false

	# Display the current question and set the text for the answer buttons
	var question = questions[current_question_index]
	question_label.text = question["question"]

	# Set text for buttons
	for i in range(4):
		buttons[i].text = question["answers"][i]

func _on_button_pressed(selected_index: int,questions) -> void:
	# Get the correct answer index
	var correct_index = questions[current_question_index]["correct"]
	
	# Disable all buttons after selection
	disable_buttons()

	# Check if the answer is correct
	if selected_index == questions["answers"]:
		# Correct answer
		buttons[selected_index].modulate = Color(0, 1, 0)  # Green for correct answer
		score += 1
	else:
		# Incorrect answer
		buttons[selected_index].modulate = Color(1, 0, 0)  # Red for incorrect answer
		
		# Also highlight the correct answer in green
		buttons[correct_index].modulate = Color(0, 1, 0)

	# Move to the next question after a brief delay
	await get_tree().create_timer(1).timeout
	next_question(questions)

func disable_buttons() -> void:
	# Disable all buttons after an answer is selected
	for button in buttons:
		button.disabled = true

func next_question(questions) -> void:
	# Move to the next question or end the quiz
	current_question_index += 1
	if current_question_index >= questions.size():
		check_game_complete()
	else:
		display_question(questions)

func check_game_complete() -> void:
	# Display the result of the quiz
	if score >= required_score:
		question_label.text = "Congratulations! You passed the quiz!\nScore: %d/%d" % [score, 4]
		
		# Hide answer buttons
		for button in buttons:
			button.visible = false
		
		# Show exit button
		exit_button.visible = true
	else:
		question_label.text = "Game over! You need at least %d correct answers to pass.\nYour score: %d/%d" % [required_score, score, 4]
		# Reset the game after a brief delay

#func reset_game() -> void:
	## Reset score and start the game over
	#score = 0
	#current_question_index = 0
	#
	## Restore buttons
	#for button in buttons:
		#button.visible = true
	#
	#display_question()

func _on_exit_pressed() -> void:
	# Exit the application when exit button is pressed
	get_tree().quit()


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		print("Success")
		var error = json.parse(body.get_string_from_utf8())
		if error == OK:
			var game_data = json.get_data()
			var question = game_data.data[0]["question"]
			display_question(question)
