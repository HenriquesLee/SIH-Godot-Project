extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	# Save the current scene's path before navigating
	var current_scene_path = get_tree().current_scene.scene_file_path
	
	# Push the current scene to the navigation stack
	SceneNavigationManager.push_scene(current_scene_path)
	
	# Navigate to the Settings scene
	get_tree().change_scene_to_file("res://scenes/others/settings.tscn")
