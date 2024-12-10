extends CharacterBody2D

# Movement speed of the player
@export var speed: float = 80.0

# Target and Arrow Settings
@onready var target_object = get_node("../NPC")  # The object/NPC the arrow will point to
@export var arrow_sprite: Sprite2D  # The arrow sprite to display
@export var rotation_offset: float = -15.0  # Rotate the arrow if needed

# Visual Customization
@export var arrow_color: Color = Color.WHITE  # Color of the arrow
@export var arrow_scale: float = 0.8  # Scale of the arrow

# Reference to the AnimatedSprite2D node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Variable to store the last movement direction
var last_direction: String = ""

# Variable to store the last played animation
var last_animation: String = "idle"

# Variable to track arrow visibility state
var is_arrow_visible: bool = false
var arrow_hide_timer: float = 0.0

func _ready():
	# Ensure the arrow is hidden initially
	if arrow_sprite:
		arrow_sprite.visible = false
		
		# Apply initial color and scale
		arrow_sprite.modulate = arrow_color
		arrow_sprite.scale = Vector2.ONE * arrow_scale

func _process(delta: float) -> void:
	# Handle Movement
	var direction = Vector2.ZERO
	
	# Check for input from arrow keys or WASD
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_backward"):
		direction.y += 1
	if Input.is_action_pressed("move_forward"):
		direction.y -= 1
	
	# Normalize the direction vector to prevent faster diagonal movement
	direction = direction.normalized()
	
	# Set the velocity
	velocity = direction * speed
	
	# Move the player
	move_and_slide()
	
	# Update animation based on movement
	if animated_sprite:
		if direction != Vector2.ZERO:
			if direction.y > 0:
				animated_sprite.play("down")
				last_animation = "down"
			elif direction.y < 0:
				animated_sprite.play("up")
				last_animation = "up"
			elif direction.x > 0:
				animated_sprite.play("side")
				animated_sprite.flip_h = true
				last_animation = "side_right"
			elif direction.x < 0:
				animated_sprite.play("side")
				animated_sprite.flip_h = false
				last_animation = "side_left"
		else:
			# Instead of playing "idle", stop on the first frame of the last animation
			animated_sprite.stop()
			
			# If it was a side animation, ensure the correct orientation is maintained
			if last_animation == "side_right":
				animated_sprite.flip_h = true
			elif last_animation == "side_left":
				animated_sprite.flip_h = false
			
			# Reset to the first frame of the last animation
			animated_sprite.frame = 1
	
	# Directional Arrow Logic
	if target_object and arrow_sprite:
		# Toggle arrow visibility when "H" key is pressed
		if Input.is_action_just_pressed("show_hint"):
			is_arrow_visible = not is_arrow_visible
			arrow_sprite.visible = is_arrow_visible
			arrow_hide_timer = 5.0  # Reset the timer
		
		# Only update arrow if it's currently visible
		if is_arrow_visible:
			# Calculate direction to target
			var direction_to_target = target_object.global_position - global_position
			
			# Calculate angle to rotate the arrow
			var angle = direction_to_target.angle()
			
			# Apply rotation offset and set arrow rotation
			arrow_sprite.rotation = angle + deg_to_rad(rotation_offset)
		
		# Decrease the hide timer if the arrow is visible
		if is_arrow_visible:
			arrow_hide_timer -= delta
			if arrow_hide_timer <= 0.0:
				is_arrow_visible = false
				arrow_sprite.visible = false
	else:
		push_warning("Target object or arrow sprite is not assigned!")
