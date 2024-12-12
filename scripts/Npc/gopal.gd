extends Node2D

var balloon_scene = preload("res://dialogues/game_balloon.tscn")
@onready var interactable_label_component: Control = $InteractableLabelComponent
@onready var interablecomponent: InteractableComponent = $interablecomponent
var in_range: bool
var json_parser = JSON.new()
@onready var http_request: HTTPRequest = $HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interablecomponent.interactable_activated.connect(on_interactable_activated)
	interablecomponent.interactable_deactivated.connect(on_interactable_deactivated)
	interactable_label_component.hide()	

func on_interactable_activated() -> void:
	interactable_label_component.show()
	in_range = true
	fetch_dialogue()


func on_interactable_deactivated() -> void:
	interactable_label_component.hide()
	in_range = false
func _unhandled_input(event: InputEvent) -> void:
	if in_range:
		if event.is_action_pressed("interact"):
			trigger_dialogue_on_start()
func fetch_dialogue():
	var post_data = {
	"area": "ex",
	"map": "ex_1",
	"collection":"executive_dialogue"
}
	var headers = ["Content-Type: application/json"]
	var response = http_request.request(Api.dialogue,headers,HTTPClient.METHOD_GET,
	JSON.stringify(post_data))
	if response != OK:
		print("An error occurred in the HTTP request.")

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		print("Success")
		var error = json_parser.parse(body.get_string_from_utf8())
		if error == OK:
			var dialogue_data = json_parser.get_data()
			# Remove existing file if it exists
			if FileAccess.file_exists("res://dialogues/coversations/gopal.dialogue"):
				DirAccess.remove_absolute("res://dialogues/coversations/gopal.dialogue")
			
			# Create dialogue file content
			var dialogue_file_content = "~ start\n"
			
			# Add dialogues from JSON
			for dialogue in dialogue_data.ex_1.npc_0:
				dialogue_file_content += dialogue.character + ": " + dialogue.dialogue + "\n"
				
			dialogue_file_content += "=> END\n"
			
			# Write new file
			var file = FileAccess.open("res://dialogues/coversations/gopal.dialogue", FileAccess.WRITE)
			file.store_string(dialogue_file_content)
			file.close()
			
	else:
		print(response_code)

func trigger_dialogue_on_start() -> void:
	var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
	get_tree().root.add_child(balloon)  # Add to the scene tree
	balloon.start(load("res://dialogues/coversations/gopal.dialogue"), "start")
