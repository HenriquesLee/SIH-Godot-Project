extends Control
var current_question = {}
var correct_index: int
var questions: Array = []
var time_in_seconds = 1

@export var json_path: String = "res://data/questions.json"
@export var section: String = "Legislature" # Default section

@onready var question_label = $TextureRect/RichTextLabel
@onready var buttons = [
	$TextureRect/Button,
	$TextureRect/Button2,
	$TextureRect/Button3,
	$TextureRect/Button4
]

func _ready():
	# Load questions
	load_questions()
	
	# Check if question_label and buttons are valid before connecting signals
	if is_instance_valid(question_label) and buttons.all(is_instance_valid):
		for i in range(buttons.size()):
			buttons[i].pressed.connect(func(): check_answer(i))
	else:
		print("One or more nodes are null")
		if !is_instance_valid(question_label):
			print("question_label is null")
		for i in range(buttons.size()):
			if !is_instance_valid(buttons[i]):
				print("Button", i, "is null")
	
	# Select and display a random question
	select_random_question()

func load_questions():
	# Check if the file exists
	if not FileAccess.file_exists(json_path):
		print("JSON file does not exist at path:", json_path)
		return
	
	# Read the file content
	var file_content = FileAccess.get_file_as_string(json_path)
	
	# Parse the JSON content
	var parse_result = JSON.parse_string(file_content)
	
	# Check if parsing was successful
	if parse_result == null:
		print("Failed to parse JSON")
		return
	
	# Get the parsed data
	var json_data = parse_result
	if section in json_data:
		questions = json_data[section]
		if questions.size() == 0:
			print("No questions available in the section:", section)
	else:
		print("Section not found in JSON:", section)

func select_random_question():
	if questions.size() == 0:
		print("No questions available.")
		return
	
	var question_data = questions[randi() % questions.size()]  # Randomly select a question
	print("Question selected:", question_data)
	set_question(question_data)

func set_question(question_data: Dictionary) -> void:
	print("Setting question with data:", question_data)
	current_question = question_data
	display_question()

func display_question() -> void:
	print("Displaying question. Current question:", current_question)
	
	if current_question.has("question") and current_question.has("answers"):
		print("Question exists. Setting text...")
		
		# Explicitly set text on question label
		if is_instance_valid(question_label):
			question_label.text = current_question["question"]
			print("Question label text set to:", current_question["question"])
		else:
			print("ERROR: question_label is not valid!")
		
		# Create a copy of the answers to shuffle
		var shuffled_answers = current_question["answers"].duplicate()
		
		# Shuffle the answers
		shuffled_answers.shuffle()
		
		# Track the correct answer's new index after shuffling
		correct_index = shuffled_answers.find(current_question["answers"][current_question["correct"]])
		
		for i in range(buttons.size()):
			if is_instance_valid(buttons[i]):
				buttons[i].text = shuffled_answers[i]
				buttons[i].disabled = false
				print("Button", i, "text set to:", shuffled_answers[i])
			else:
				print("ERROR: Button", i, "is not valid!")
	else:
		print("Invalid question data")

func check_answer(index: int) -> void:
	# Disable all buttons after an answer is selected
	for button in buttons:
		button.disabled = true
	
	# Check if the selected answer is correct
	if index == correct_index:
		buttons[index].modulate = Color(0, 1, 0)  # Green for correct answer
	else:
		buttons[index].modulate = Color(1, 0, 0)  # Red for wrong answer
		buttons[correct_index].modulate = Color(0, 1, 0)  # Green for correct answer
	
	# Create a timer to return to main scene
	var return_timer = get_tree().create_timer(time_in_seconds)
	return_timer.timeout.connect(func():
		# Replace with actual scene transition
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)
