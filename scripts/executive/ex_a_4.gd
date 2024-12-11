extends Node2D
@onready var reading_material: CanvasLayer = $script


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_chest1_area_entered(area: Area2D) -> void:
	reading_material.show()




func _on_chest_1_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	pass # Replace with function body.
