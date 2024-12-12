extends Control
var required_score = 3
@onready var return_button = $Button

var constitution_facts = [
	{
		"statement": "Article 51 deals with the fundamental duty of citizens to promote harmony and the spirit of national integration.",
		"is_correct": true,
		"explanation": "Article 51 outlines the fundamental duties of citizens, specifically emphasizing the promotion of harmony and the spirit of national integration across diverse religious, linguistic, and regional groups."
	},
	{
		"statement": "Article 52 of the Constitution defines the role of the Prime Minister as the head of the government.",
		"is_correct": false,
		"explanation": "Article 52 actually establishes the President of India. The role of the Prime Minister is defined in other articles of the Constitution."
	},
	{
		"statement": "Article 53 vests the executive power of the Union entirely in the Prime Minister.",
		"is_correct": false,
		"explanation": "Article 53 vests the executive power of the Union in the President, who may exercise these powers directly or through officers subordinate to them, in accordance with the Constitution."
	},
	{
		"statement": "According to Article 51, citizens must protect the environment and have compassion for living creatures.",
		"is_correct": true,
		"explanation": "Article 51 includes fundamental duties that emphasize environmental protection and compassion for all living creatures as part of fundamental duties added by the 42nd Amendment."
	},
	{
		"statement": "Article 53 allows the President to delegate all executive powers completely without any restrictions.",
		"is_correct": false,
		"explanation": "While Article 53 allows the President to exercise executive powers through subordinate officers, there are constitutional limitations and the President remains ultimately responsible."
	}
]

var current_fact_index = 0
var score = 0

var card_label: Label
var wrong_button: Button
var right_button: Button
var explanation_label: Label
var score_label: Label

func _ready():
	setup_ui()
	display_fact()
		# Connect return button
	if return_button:
		return_button.pressed.connect(return_to_previous_scene)
	else:
		print("Warning: Return Button not found in the scene!")

func setup_ui():
	# Set background color using StyleBoxFlat
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.85, 0.85, 0.95)  # Light blue-gray background
	add_theme_stylebox_override("panel", style_box)
	
	# Create main vertical container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 20)
	add_child(main_container)
	
	# Title Label
	var title_label = Label.new()
	title_label.text = "Constitution Articles 51-53 Card Gmae"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	main_container.add_child(title_label)
	
	# Card Container
	var card_container = CenterContainer.new()
	card_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(card_container)
	
	# Card Panel - INCREASED SIZE
	var card_panel = Panel.new()
	card_panel.custom_minimum_size = Vector2(600, 400)  # Larger card size
	
	# Add a StyleBoxFlat to card panel for white background
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color.WHITE
	card_style.set_corner_radius_all(20)  # Rounded corners
	card_style.content_margin_left = 20
	card_style.content_margin_right = 20
	card_style.content_margin_top = 20
	card_style.content_margin_bottom = 20
	card_panel.add_theme_stylebox_override("panel", card_style)
	
	card_container.add_child(card_panel)
	
	# Card Layout
	var card_layout = VBoxContainer.new()
	card_panel.add_child(card_layout)
	
	# Card Label - ADJUSTED FOR LARGER CARD
	card_label = Label.new()
	card_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	card_label.custom_minimum_size = Vector2(560, 300)  # Matching larger card size
	card_label.add_theme_font_size_override("font_size", 20)
	card_label.add_theme_color_override("font_color", Color.BLACK)
	card_layout.add_child(card_label)
	
	# Explanation Label
	explanation_label = Label.new()
	explanation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	explanation_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	explanation_label.custom_minimum_size = Vector2(560, 80)
	explanation_label.visible = false
	explanation_label.add_theme_font_size_override("font_size", 16)
	card_layout.add_child(explanation_label)
	
	# Buttons Container
	var button_container = HBoxContainer.new()
	button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_container.add_child(button_container)
	
	# Wrong Button
	wrong_button = Button.new()
	wrong_button.text = "Wrong"
	wrong_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrong_button.add_theme_color_override("font_color", Color.WHITE)
	wrong_button.add_theme_stylebox_override("normal", create_colored_stylebox(Color.RED))
	wrong_button.pressed.connect(func(): check_answer(false))
	button_container.add_child(wrong_button)
	
	# Right Button
	right_button = Button.new()
	right_button.text = "Right"
	right_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_button.add_theme_color_override("font_color", Color.WHITE)
	right_button.add_theme_stylebox_override("normal", create_colored_stylebox(Color.GREEN))
	right_button.pressed.connect(func(): check_answer(true))
	button_container.add_child(right_button)
	
	# Score Label
	score_label = Label.new()
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.text = "Score: 0 / " + str(constitution_facts.size())
	main_container.add_child(score_label)

# Helper function to create styled buttons
func create_colored_stylebox(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(5)
	style.content_margin_bottom = 10
	style.content_margin_top = 10
	return style

func display_fact():
	if current_fact_index < constitution_facts.size():
		var fact = constitution_facts[current_fact_index]
		card_label.text = fact["statement"]
		explanation_label.text = ""
		explanation_label.visible = false
		wrong_button.disabled = false
		right_button.disabled = false
	else:
		# Game over screen
		card_label.text = "Quiz Completed!\nScore: %d / %d" % [score, constitution_facts.size()]
		wrong_button.disabled = true
		right_button.disabled = true

func check_answer(selected_answer: bool):
	var current_fact = constitution_facts[current_fact_index]
	
	if selected_answer == current_fact["is_correct"]:
		score += 1
		explanation_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		explanation_label.add_theme_color_override("font_color", Color.RED)
	
	explanation_label.text = current_fact["explanation"]
	explanation_label.visible = true
	
	# Update score label
	
	if score >= required_score:
		score_label.text = "Congratulations! You passed the quiz!\nScore: %d/" % [score]
	else:
		score_label.text = "Game over! You need at least %d correct answers to pass.\nYour score: %d/%d" % [required_score, score]
	wrong_button.disabled = true
	right_button.disabled = true
	
	# Use a timer to show explanation before next fact
	var timer = get_tree().create_timer(2.0)
	await timer.timeout
	
	current_fact_index += 1
	display_fact()


func return_to_previous_scene():
	# Get the top scene from the stack
	var previous_scene = SceneNavigationManager.pop_scene()
	
	if previous_scene and previous_scene != "":
		# Change to the previous scene
		get_tree().change_scene_to_file(previous_scene)
	else:
		print("No previous scene available!")
