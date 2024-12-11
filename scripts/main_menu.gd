extends Control
var button_type = null
@onready var fade_transition: ColorRect = $Fade_transition

func _on_start_pressed() -> void:
	button_type = "start"
	$Fade_transition.show()
	$Fade_transition/Timer.start()
	$Fade_transition/AnimationPlayer.play("Fade_in")
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_timer_timeout() -> void:
	if button_type == "start":
		get_tree().change_scene_to_file("res://scenes/others/base map.tscn")
 # Replace with function body.


func _on_button_pressed() -> void:
	# Save the current scene's path before navigating
	var current_scene_path = get_tree().current_scene.scene_file_path
	
	# Push the current scene to the navigation stack
	SceneNavigationManager.push_scene(current_scene_path)
	
	# Navigate to the Settings scene
	get_tree().change_scene_to_file("res://scenes/others/settings.tscn")
