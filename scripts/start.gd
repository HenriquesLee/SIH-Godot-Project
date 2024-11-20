extends Node2D

var balloon_scene = preload("res://dialogues/game_balloon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/Fade_transition.show()
	$CanvasLayer/Fade_transition/AnimationPlayer.play("Fade_out")
	trigger_dialogue_on_start()
	
func trigger_dialogue_on_start() -> void:
	var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
	get_tree().root.add_child(balloon)  # Add to the scene tree
	balloon.start(load("res://dialogues/coversations/self.dialogue"), "Chinu")
