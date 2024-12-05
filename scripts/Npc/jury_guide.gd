extends Node2D

var balloon_scene = preload("res://dialogues/game_balloon.tscn")

@onready var interactablecomponent: InteractableComponent = $interactablecomponent
@onready var interactable_label_component: Control = $InteractableLabelComponent
var in_range: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactablecomponent.interactable_activated.connect(on_interactable_activated)
	interactablecomponent.interactable_deactivated.connect(on_interactable_deactivated)
	interactable_label_component.hide()	

func on_interactable_activated() -> void:
	interactable_label_component.show()
	in_range = true



func on_interactable_deactivated() -> void:
	interactable_label_component.hide()
	in_range = false

# Called every frame. 'wawwawdelta' is the elapsed time since the previous frame.
#func _unhandled_input(event: InputEvent) -> void:
	#if in_range:
		#if event.is_action_pressed("interact"):
			#var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
			#get_tree().root.add_child(balloon)
			#balloon.start(load("res://dialogues/coversations/first_interaction.dialogue"), "Villager")
