extends Button

# Path to the AI scene
@export var target_scene: String = "res://scenes/others/settings.tscn"

func _ready():
	# Connect the button's pressed signal to the navigation function
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	# Save the current scene's path before navigating
	var current_scene_path = get_tree().current_scene.scene_file_path
	
	# Push the current scene to the navigation stack
	SceneNavigationManager.push_scene(current_scene_path)
	
	# Navigate to the target scene
	get_tree().change_scene_to_file(target_scene)
