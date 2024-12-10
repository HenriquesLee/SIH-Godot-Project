extends Node2D
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var form_popup: Control = preload("res://scenes/others/form.tscn").instantiate()

var _save : SaveGame
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Controls.show()
	$CanvasLayer/Fade_transition.show()
	$CanvasLayer/Fade_transition/AnimationPlayer.play("Fade_out")
	$CanvasLayer.add_child(form_popup)
	form_popup.show()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_executive_path_body_entered(body: Node2D) -> void:
	print("Intreacted")
	$CanvasLayer/Fade_transition.show()
	$CanvasLayer/Fade_transition/AnimationPlayer.play("Fade_in")
	get_tree().change_scene_to_file("res://scenes/ex_a1/ex_a1.tscn") # Replace with function body.
	

func _on_legislative_path_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_judiciary_ptath_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	_create_or_load_gmae()
	
func _create_or_load_gmae() -> void:
	if SaveGame.save_exists():
		_save = SaveGame.load_savegame() as SaveGame
	else :
		_save = SaveGame.new()
		_save.character = Character.new()
		_save.character.user_id =UserData.UserId
		_save.write_savegame()
		
