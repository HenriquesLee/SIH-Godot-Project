extends Control

@export var main_menu_path: String = "res://scenes/main_menu.tscn"  # Explicit scene path
@export var logo_display_time: float = 4.0
@export var fade_duration: float = 1.5

func _ready() -> void:
	# Debug print to confirm script is running
	print("Splash Screen Initialized")
	
	# Ensure screen is opaque
	modulate.a = 1.0
	
	# Create tween for animation
	var tween = create_tween()
	
	# Hold logo
	tween.tween_interval(logo_display_time)
	
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	# Load main menu after fade
	tween.tween_callback(load_main_menu)

func load_main_menu() -> void:
	# Comprehensive debug logging
	print("Attempting to load main menu...")
	print("Main Menu Path: ", main_menu_path)
	
	# Load scene directly
	var main_menu_scene = load(main_menu_path)
	
	if main_menu_scene == null:
		print("ERROR: Could not load main menu scene!")
		return
	
	# Multiple scene change methods for reliability
	var error = get_tree().change_scene_to_packed(main_menu_scene)
	
	if error != OK:
		print("Scene change failed. Error code: ", error)
		# Fallback method
		get_tree().change_scene_to_file(main_menu_path)
