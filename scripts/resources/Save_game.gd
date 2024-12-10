class_name SaveGame
extends Resource

const SAVE_GAME_PATH := "user://save"

@export var version := 1
@export var character: Resource = Character.new()
@export var global_position := Vector2.ZERO

func write_savegame() -> void:
	ResourceSaver.save(self, get_save_path())

static func save_exists() -> bool:
	return ResourceLoader.exists(get_save_path())

static func load_savegame() -> Resource:
	var save_path := get_save_path()
	if ResourceLoader.has_cached(save_path):
		return ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	
	# Workaround for sub-resources loading
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		printerr("Couldn't read file " + save_path)
		return null
	
	var data := file.get_buffer(file.get_length())
	file.close()
	
	# Generate a random file path that's not in Godot's cache
	var tmp_file_path := make_random_path()
	while ResourceLoader.has_cached(tmp_file_path):
		tmp_file_path = make_random_path()
	
	# Write a copy of the save game to temporary file path
	var tmp_file := FileAccess.open(tmp_file_path, FileAccess.WRITE)
	if tmp_file == null:
		printerr("Couldn't write file " + tmp_file_path)
		return null
	
	tmp_file.store_buffer(data)
	tmp_file.close()
	
	# Load the temporary file as a resource
	var save = ResourceLoader.load(tmp_file_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	
	# Make it take over the save path for the next time the player saves
	save.take_over_path(save_path)
	
	# Delete the temporary file
	DirAccess.remove_absolute(tmp_file_path)
	
	return save

static func make_random_path() -> String:
	return "user://temp_file_" + str(randi()) + ".tres"

static func get_save_path() -> String:
	var extension := ".tres" if OS.is_debug_build() else ".res"
	return SAVE_GAME_PATH + extension
