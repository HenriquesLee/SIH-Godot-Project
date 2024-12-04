extends Control

# Variables for the quiz
var current_question_index = 0
var score = 0
var required_score = 3  # Minimum score to pass
var questions = [
	{"question": "What is the President prohibited from doing while in office?", 
	 "answers": ["Running for re-election", "Holding any office of profit", 
				 "Resigning before their term ends", "Presiding over Parliament sessions"], 
	 "correct": 1},
	{"question": "What majority is required for impeachment of the President?", 
	 "answers": ["Simple majority", "Two-thirds majority in both Houses of Parliament", 
				 "Absolute majority in Lok Sabha", "Three-fourths majority in Rajya Sabha"], 
	 "correct": 1},
	{"question": "Who acts as President when the position is vacant?", 
	 "answers": ["Prime Minister", "Vice-President", 
				 "Chief Justice of India", "Governor of the largest state"], 
	 "correct": 1},
	{"question": "What is the Vice-President's primary role in Parliament?", 
	 "answers": ["Preside over the Rajya Sabha", "Advise the Prime Minister", 
				 "Appoint the President", "Propose state laws"], 
	 "correct": 0}
]

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
	display_question()

	# Connect button signals
	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_button_pressed.bind(i))
	
	# Connect exit button and hide it initially
	exit_button.pressed.connect(_on_exit_pressed)
	exit_button.visible = false

func display_question() -> void:
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

func _on_button_pressed(selected_index: int) -> void:
	# Get the correct answer index
	var correct_index = questions[current_question_index]["correct"]
	
	# Disable all buttons after selection
	disable_buttons()

	# Check if the answer is correct
	if selected_index == correct_index:
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
		# Reset the game after a brief delay
		await get_tree().create_timer(2).timeout
		reset_game()

func reset_game() -> void:
	# Reset score and start the game over
	score = 0
	current_question_index = 0
	
	# Restore buttons
	for button in buttons:
		button.visible = true
	
	display_question()

func _on_exit_pressed() -> void:
	# Exit the application when exit button is pressed
	get_tree().quit()
