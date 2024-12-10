extends Node2D
@export var spin_duration: float = 3.0 # Spin duration in seconds
var is_spinning: bool = false
var angular_velocity: float = 0.0
@export var json_path: String = "res://data/questions.json"
@export var section: String = "Legislature" # Default section
var time_in_seconds = 1

func _process(delta: float):
	if is_spinning:
		rotation_degrees += angular_velocity * delta

func spin_wheel():
	if is_spinning:
		return
	is_spinning = true
	var random_spin = randf_range(100, 300) # Random spin force
	angular_velocity = random_spin
	await get_tree().create_timer(spin_duration).timeout
	stop_wheel()

func stop_wheel():
	angular_velocity = 0
	var final_angle = int(rotation_degrees) % 360
	final_angle = round(final_angle / 45.0) * 45.0
	if final_angle < 0:
		final_angle += 360
	rotation_degrees = final_angle
	is_spinning = false
	transition_to_quiz_scene()

func transition_to_quiz_scene():
	await get_tree().create_timer(time_in_seconds).timeout
	var quiz_game_scene = preload("res://scenes/mini_games/spin_the_wheel/quiz_game.tscn").instantiate()
	get_tree().current_scene.queue_free()
	get_tree().root.add_child(quiz_game_scene)
	get_tree().current_scene = quiz_game_scene
