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
		get_tree().change_scene_to_file("res://scenes/ex_a1/ex_a1.tscn")
 # Replace with function body.
