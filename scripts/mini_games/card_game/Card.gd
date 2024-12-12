extends Node2D

signal hovered
signal hovered_off
signal option_selected # Signal to emit when an option is selected

var starting_position
var question = ""
var options = []
var correct_answers = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Set the question, options, and correct answers for this card
func set_question(data):
	question = data["question"]
	options = data["options"]
	correct_answers = data["correct_answers"]
	display_question_and_options()

# Display the question and options (update UI nodes)
func display_question_and_options():
	$QuestionLabel.text = question
	for i in range(len(options)):
		var option_button = $OptionsContainer.get_child(i)
		option_button.text = options[i]
		option_button.visible = true

# Handle mouse hover events
func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)

# Handle option selection
func on_option_pressed(index):
	emit_signal("option_selected", self, index)

# Return the correct answers for validation
func get_correct_answers():
	return correct_answers
