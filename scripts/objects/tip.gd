extends TextureRect
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var label_2: Label = $Label2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fetch_tip_of_the_day()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fetch_tip_of_the_day():
	var headers = ["Content-Type: application/json"]
	var response = http_request.request("https://flaskserver-rho.vercel.app/fact",headers,HTTPClient.METHOD_GET)
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json = JSON.new()
		var error = json.parse(body.get_string_from_utf8())
		if error == OK:
			var tip = json.get_data()
			label_2.text = tip["data"]
		else:
			print("No questions received from the server")
	else:
		print("HTTP Request failed with response code: ", response_code)
