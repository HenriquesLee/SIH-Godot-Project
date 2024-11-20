extends BaseGameDialogueBalloon
@onready var talksound: AudioStreamPlayer = $Talksound

func _on_dialogue_label_spoke(letter: String, letter_index: int, speed: float) -> void:
	if not letter in["."," "]:
		talksound.play() # Replace with function body.
