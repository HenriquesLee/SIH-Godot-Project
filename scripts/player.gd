extends CharacterBody2D

# Movement speed of the player
@export var speed: float = 200.0

# Reference to the AnimatedSprite2D node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Variable to store the last movement direction
var last_direction: String = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Get input direction
	var direction = Vector2.ZERO

	# Check for input from arrow keys or WASD
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	# Normalize the direction vector to prevent faster diagonal movement
	direction = direction.normalized()

	# Set the velocity
	velocity = direction * speed

	# Move the player
	move_and_slide()

	# Update animation based on movement
	if animated_sprite:  # Check if animated_sprite is not null
		if direction != Vector2.ZERO:
			if direction.y > 0:
				animated_sprite.play("down")  # Play down animation
			elif direction.y < 0:
				animated_sprite.play("up")    # Play up animation
			elif direction.x > 0:
				animated_sprite.play("side") # Play right animation
				animated_sprite.flip_h = true
			elif direction.x < 0:
				animated_sprite.play("side")  # Play left animation
				animated_sprite.flip_h = false
		else:
			# Stop the animation and set to the first frame of the last direction
			if last_direction != "":
				animated_sprite.play(last_direction)
				animated_sprite.frame = 0  # Set to the first frame of the last direction
			else:
				animated_sprite.stop()  # Stop the animation when not moving
