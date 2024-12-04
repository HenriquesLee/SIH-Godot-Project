extends Control
@onready var line_edit: LineEdit = $TextureRect/LineEdit
@onready var line_edit_2: LineEdit = $TextureRect/LineEdit2
@onready var submit: TextureButton = $TextureRect/Submit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_pressed() -> void:
	if line_edit.text.strip_edges() == "" or line_edit_2.text.strip_edges() == "":
		print("Please fill in all fields before submitting.")
	else:
		print(line_edit.text, line_edit_2.text)
		line_edit.clear()
		line_edit_2.clear()
