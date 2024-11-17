extends Node2D

var balloon_scene = preload("res://dialogues/game_balloon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("intial_dialogue"):
		trigger_dialogue_on_interact()

# Trigger dialogue after "interact" action
func trigger_dialogue_on_interact() -> void:
	var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
	get_tree().root.add_child(balloon)  # Add to the scene tree
	balloon.start(load("res://dialogues/coversations/self.dialogue"), "Chinu")
