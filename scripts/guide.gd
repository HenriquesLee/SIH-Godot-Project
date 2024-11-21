extends Node2D
@onready var interactablecomponent: InteractableComponent = $interactablecomponent


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactablecomponent.interactable_activated.connect(on_interactable_activated)
	
func on_interactable_activated() -> void:
	get_tree().change_scene_to_file("res://scenes/village2.tscn")
