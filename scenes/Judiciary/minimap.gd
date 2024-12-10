extends Node2D

@onready var camera = $SubViewport/Camera2D
@onready var player = get_node("./player")  # Adjust the path to your player node
@onready var texture_rect = $TextureRect

func _process(delta):
	# Update the camera position to follow the player
	camera.position = player.position

	# Update the TextureRect to show the SubViewport's texture
	texture_rect.texture = $SubViewport.get_texture()
