extends TextureProgressBar

# Progress Configuration
@export var max_progress: float = 100.0
@export var progress_speed: float = 10.0
@export var auto_progress: bool = true

# Progress State Variables
var current_progress: float = 0.0
var is_completed: bool = false

# Game Progression Signals
signal progress_started
signal progress_updated(value)
signal progress_completed

# Initialize Progress Bar
func _ready() -> void:
	# Configure initial progress bar settings
	max_value = max_progress
	value = 0
	
	# Emit signal when progress begins
	if auto_progress:
		emit_signal("progress_started")

# Update Progress Each Frame
func _process(delta: float) -> void:
	if not is_completed and auto_progress:
		update_progress(delta)

# Progress Update Logic
func update_progress(delta: float) -> void:
	# Increment progress based on game time
	current_progress += progress_speed * delta
	
	# Clamp progress value
	current_progress = clamp(current_progress, 0, max_progress)
	
	# Update visual progress bar
	value = current_progress
	
	# Emit progress update signal
	emit_signal("progress_updated", current_progress)
	
	# Check for completion
	if current_progress >= max_progress:
		complete_progress()

# Complete Progress
func complete_progress() -> void:
	is_completed = true
	emit_signal("progress_completed")
	
	# Optional: Additional completion logic
	print("Progress completed!")

# Manual Progress Control Methods
func reset_progress() -> void:
	current_progress = 0
	value = 0
	is_completed = false
	
	# Restart auto progress if enabled
	if auto_progress:
		emit_signal("progress_started")

# Set Specific Progress Value
func set_progress(amount: float) -> void:
	current_progress = clamp(amount, 0, max_progress)
	value = current_progress
	
	# Check if completed after manual setting
	if current_progress >= max_progress:
		complete_progress()

# Add Progress Incrementally
func add_progress(amount: float) -> void:
	current_progress += amount
	current_progress = clamp(current_progress, 0, max_progress)
	value = current_progress
	
	# Emit update signal
	emit_signal("progress_updated", current_progress)
	
	# Check for completion
	if current_progress >= max_progress:
		complete_progress()

# Game Integration Example
func _on_game_event_occurred() -> void:
	# Trigger progress based on game events
	add_progress(10.0)

# Optional: Pause/Resume Progression
func pause_progress() -> void:
	set_process(false)

func resume_progress() -> void:
	set_process(true)
