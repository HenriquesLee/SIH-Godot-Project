extends Node2D

var balloon_scene = preload("res://dialogues/game_balloon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Controls.show()
	$CanvasLayer/Fade_transition.show()
	$CanvasLayer/Fade_transition/AnimationPlayer.play("Fade_out")
	
