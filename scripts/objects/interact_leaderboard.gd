extends Sprite2D
@onready var interablecomponent: InteractableComponent = $interablecomponent
@onready var interactable_label_component: Control = $InteractableLabelComponent
var in_range: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interablecomponent.interactable_activated.connect(on_interactable_activated)
	interablecomponent.interactable_deactivated.connect(on_interactable_deactivated)
	interactable_label_component.hide()

func on_interactable_activated() -> void:
	interactable_label_component.show()
	in_range = true
	
func on_interactable_deactivated() -> void:
	interactable_label_component.hide()
	in_range = false
func _unhandled_input(event: InputEvent) -> void:
	if in_range:
		if event.is_action_pressed("interact"):
			get_tree().change_scene_to_file("res://scenes/others/leaderboard.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
