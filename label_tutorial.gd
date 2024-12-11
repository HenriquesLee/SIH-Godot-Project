extends Label



func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("skip"):
		get_tree().change_scene_to_file("res://scenes/others/settings.tscn")
