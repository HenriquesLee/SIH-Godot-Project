extends Control

# HTTP Request node
@onready var http_request = $HTTPRequest
# Container for leaderboard entries
@onready var label: Label = $Label

var json = JSON.new()


func _ready():
	# Ensure HTTPRequest node is configured to use JSON
	http_request.connect("request_completed", Callable(self, "_on_request_completed"))
	
	# Fetch leaderboard data when the scene loads
	fetch_leaderboard()

func fetch_leaderboard():
	# Create an HTTP request to fetch leaderboard data
	var error = http_request.request(Api.leaderboard)
	if error != OK:
		printerr("An error occurred in the HTTP request: ", error)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var error = json.parse(body.get_string_from_utf8())
		if error == OK:
			var response_data = json.get_data()
			var leaderboard = response_data["leaderboard"]
			print(leaderboard)
			for index in range(leaderboard.size()):
				var entry = leaderboard[index]
				#var username = entry["username"]
				#var score = entry["score"]
				label.text = "%d. %s - Score: %d" % [index + 1, entry["username"], entry["score"]]
				
