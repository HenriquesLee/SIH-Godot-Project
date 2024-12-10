extends Control

var current_question_index = 0
var score = 0
var required_score = 3  # Minimum score to pass
@onready var exit_button: Button = $TextureRect/ExitButton

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
var questions = [
	{
		"question": "How is the Vice-President elected?",
		"options": ["By Members of Legislative Assemblies", "By an Electoral College of MPs", "By citizens directly"],
		"correct_index": 1
	},
	{
		"question": "Which body resolves disputes regarding the election of the President?",
		"options": ["Election Commission", "Lok Sabha", "Supreme Court"],
		"correct_index": 2
	},
	{
		"question": "What special power does the President hold under Article 72?",
		"options": ["Declare a state of emergency", "Grant pardons for offenses", "Dissolve Parliament"],
		"correct_index": 1
	},
	{
		"question": "What is the term length for the Vice-President?",
		"options": ["4 years", "5 years", "6 years"],
		"correct_index": 1
	}
]

func _ready():
	# Initial setup
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
	var current_question = questions[current_question_index]
	crowd_texture.get_child(0).text = current_question["question"]
	button1.text = current_question["options"][0]
	button2.text = current_question["options"][1]
	button3.text = current_question["options"][2]
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
	if selected_index == current_question["correct_index"]:
		# Correct answer
		buttons[selected_index].modulate = Color(0, 1, 0)  # Green for correct answer
		score += 1
	else:
		# Incorrect answer
		buttons[selected_index].modulate = Color(1, 0, 0)  # Red for incorrect answer
		
		# Find and highlight the correct answer in green
		for i in range(buttons.size()):
			if i == current_question["correct_index"]:
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
