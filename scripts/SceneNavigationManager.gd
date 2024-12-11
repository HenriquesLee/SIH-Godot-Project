extends Node

# Singleton/Autoload script to manage scene navigation

var previous_scene_path: String = ""

func change_scene(new_scene_path: String):
	# Store the current scene path before changing
	previous_scene_path = get_tree().current_scene.scene_file_path
	print("Storing previous scene path: ", previous_scene_path)
	
	# Change to the new scene
	get_tree().change_scene_to_file(new_scene_path)

func get_previous_scene_path() -> String:
	print("Retrieved previous scene path: ", previous_scene_path)
	return previous_scene_path

func clear_previous_scene_path():
	previous_scene_path = ""
	
# Stack to store scene navigation history
var scene_stack: Array = []

# Push a scene onto the stack
func push_scene(scene_path: String):
	print("Pushing scene to stack: ", scene_path)
	scene_stack.push_front(scene_path)
	print("Current stack: ", scene_stack)

# Pop the top scene from the stack
func pop_scene() -> String:
	print("Current stack before pop: ", scene_stack)
	if not scene_stack.is_empty():
		var top_scene = scene_stack.pop_front()
		print("Popped scene: ", top_scene)
		print("Remaining stack: ", scene_stack)
		return top_scene
	
	print("Scene stack is empty!")
	return ""

# Peek at the top scene without removing it
func peek_scene() -> String:
	if not scene_stack.is_empty():
		return scene_stack[0]
	return ""

# Clear the entire scene stack
func clear_scene_stack():
	scene_stack.clear()
	print("Scene stack cleared")
