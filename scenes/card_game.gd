extends Control

# References to nodes in the scene
@onready var setting_menu = $SettingMenu
@onready var report_button = $SettingMenu/Button4
@onready var tutorial_button = $TutorialButton
@onready var video_player = $VideoStreamPlayer
@onready var card_slot_1 = $CardSlot1
@onready var card_slot_2 = $CardSlot2
@onready var question_label = $QuestionLabel
@onready var option_buttons = [$OptionButton1, $OptionButton2, $OptionButton3, $OptionButton4]

# Video stream for the tutorial
@export var tutorial_video: VideoStream

# Questions and answers
var questions = [
	{
		"question": "What does Article 153 of the Constitution of India deal with?",
		"options": [
			"Appointment of Governors for States",
			"Term of office of the President of India", 
			"Distribution of executive powers in States",
			"Provision of one Governor for each state"
		],
		"correct_answers": [0, 3]
	},
	{
		"question": "What does Article 154 of the Constitution of India establish?",
		"options": [
			"Executive power is vested in the Governor",
			"The President can override the Governor's decisions",
			"Governors have executive powers over laws and policies",
			"The Governor's executive powers are subject to the President's discretion"
		],
		"correct_answers": [0, 2]
	},
	{
		"question": "Who appoints the Governor of a State according to Article 155?",
		"options": [
			"The President of India",
			"The Chief Justice of India",
			"The Parliament of India",
			"The Prime Minister of India"
		],
		"correct_answers": [0, 3]
	},
	{
		"question": "How long does a Governor hold office according to Article 156?",
		"options": [
			"5 years from the date of appointment",
			"Indefinite term unless removed",
			"Until the President of India decides",
			"As long as the state government remains in power"
		],
		"correct_answers": [0, 1]
	}
]

var current_question_index = 0

func _ready():
	# Ensure Button4 (Report button) is connected
	$SettingMenu/Button4.pressed.connect(_on_report_button_pressed)
	
	# Connect the tutorial button pressed signal
	tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	
	# Ensure the video player is not playing by default
	video_player.stop()
	
	# Start the first question
	show_next_question()

func _on_tutorial_button_pressed():
	# Check if a tutorial video is assigned
	if tutorial_video:
		# Set the video stream and start playing
		video_player.stream = tutorial_video
		video_player.play()
	else:
		print("No tutorial video assigned!")

func _on_report_button_pressed():
	# Create and show the feedback popup
	var popup = create_feedback_popup()
	add_child(popup)
	popup.popup_centered()

func create_feedback_popup() -> PopupPanel:
	# Code to create the feedback popup remains the same as before
	# ...
	return feedback_popup

func show_next_question():
	# Get the current question
	var current_question = questions[current_question_index]
	
	# Set the question text
	question_label.text = current_question.question
	
	# Set the option buttons
	for i in range(option_buttons.size()):
		option_buttons[i].text = current_question.options[i]
	
	# Reset the card slots
	card_slot_1.card_in_slot = false
	card_slot_2.card_in_slot = false
	
	# Connect the button pressed signals
	for i in range(option_buttons.size()):
		option_buttons[i].pressed.connect(func(): _on_option_button_pressed(i))
	
	# Increment the question index
	current_question_index += 1

func _on_option_button_pressed(index):
	# Get the current question
	var current_question = questions[current_question_index - 1]
	
	# Check if the selected option is correct
	if index in current_question.correct_answers:
		# Correct answer, glow green
		option_buttons[index].modulate = Color(0, 1, 0)
		
		# Add the correct answers to the card slots
		if not card_slot_1.card_in_slot:
			card_slot_1.card_in_slot = true
			card_slot_1.modulate = Color(0, 1, 0)
		elif not card_slot_2.card_in_slot:
			card_slot_2.card_in_slot = true
			card_slot_2.modulate = Color(0, 1, 0)
	else:
		# Incorrect answer, glow red
		option_buttons[index].modulate = Color(1, 0, 0)
	
	# Disconnect the button pressed signals
	for i in range(option_buttons.size()):
		option_buttons[i].pressed.disconnect(func(): _on_option_button_pressed(i))
	
	# Check if all questions are answered
	if current_question_index == questions.size():
		# Display the final score
		var total_correct = card_slot_1.card_in_slot + card_slot_2.card_in_slot
		print("Final score: ", total_correct, " out of 4")
	else:
		# Move to the next question
		show_next_question()
