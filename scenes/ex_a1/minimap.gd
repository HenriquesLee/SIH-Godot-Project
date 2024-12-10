extends CanvasLayer

@onready var sub_viewport = $SubViewportContainer/SubViewport
@onready var camera = $Camera
@onready var texture_rect = $TextureRect
@onready var player: Node2D = get_node("../player")

func _ready():
	call_deferred("setup_minimap")

func setup_minimap():
	# Validate critical nodes
	if not sub_viewport or not camera or not texture_rect or not player:
		push_error("Missing critical nodes!")
		return

	# Configure SubViewport
	sub_viewport.size = Vector2(200, 200)  # Larger size for better visibility
	sub_viewport.transparent_bg = false  # Show full background
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	# Configure Camera
	camera.scale = Vector2(0.2, 0.2)  # Scale down the camera view
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 10

	# Set minimap texture
	if sub_viewport.get_texture():
		texture_rect.texture = sub_viewport.get_texture()
		texture_rect.custom_minimum_size = sub_viewport.size
	else:
		push_error("Failed to retrieve SubViewport texture")

func _process(delta):
	# Update camera position to follow player
	if is_instance_valid(player) and is_instance_valid(camera):
		camera.position = player.positione 2
