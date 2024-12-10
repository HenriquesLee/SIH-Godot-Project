extends Control

var time_in_seconds = 5
var progress_bar: ProgressBar
var progress_timer: Timer
var custom_font: FontVariation

func _ready():
	# Load and set custom font
	custom_font = FontVariation.new()

   


	progress_bar = $ProgressBar
	progress_bar.value = 0
	progress_bar.max_value = 100
	
	var return_timer = get_tree().create_timer(time_in_seconds)
	return_timer.timeout.connect(_on_return_timer_timeout)
	
	update_progress_bar(time_in_seconds)

func update_progress_bar(duration: float):
	var step = 100.0 / duration
	
	progress_timer = Timer.new()
	progress_timer.wait_time = 1.0
	progress_timer.one_shot = false
	progress_timer.timeout.connect(func(): _on_progress_timer_timeout(step))
	add_child(progress_timer)
	progress_timer.start()

func _on_progress_timer_timeout(step: float):
	progress_bar.value += step
	
	if progress_bar.value >= progress_bar.max_value:
		progress_bar.value = progress_bar.max_value
		progress_timer.stop()

func _on_return_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/others/main_menu.tscn")
