extends Control

const API_KEY = "AIzaSyBE3aaQanFxtxgcFJSe8WPPXWqPQmV5Q8w"
const SEARCH_QUERY = "Legislative, indian constitution, long form"
const MAX_RESULTS = 7

@onready var video_container = $VBoxContainer
@onready var return_button = $ReturnButton

func return_to_previous_scene():
	# Get the top scene from the stack
	var previous_scene = SceneNavigationManager.pop_scene()
	
	if previous_scene and previous_scene != "":
		# Change to the previous scene
		get_tree().change_scene_to_file(previous_scene)
	else:
		print("No previous scene available!")


func _ready():
	if not video_container:
		print("Error: VBoxContainer not found in the scene!")
		return
		# Connect return button
	if return_button:
		return_button.pressed.connect(return_to_previous_scene)
	else:
		print("Warning: Return Button not found in the scene!")
	
	# Ensure the VBoxContainer uses vertical layout and expands
	video_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	video_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	fetch_youtube_videos()

func fetch_youtube_videos():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_request_completed)
	
	var url = (
		"https://www.googleapis.com/youtube/v3/search" +
		"?part=snippet" +
		"&q=" + ("%s" % SEARCH_QUERY).uri_encode() +
		"&type=video" +
		"&maxResults=" + str(MAX_RESULTS) +
		"&key=" + API_KEY
	)
	
	var error = http_request.request(url)
	if error != OK:
		print("An error occurred while fetching YouTube videos. Error code: ", error)

func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("YouTube API request failed with response code: ", response_code)
		return
	
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		print("Failed to parse JSON response")
		return
	
	var response = json.get_data()
	
	# Clear any existing children
	for child in video_container.get_children():
		child.queue_free()
	
	if not response.has("items"):
		print("No videos found")
		return
	
	# Create video entries
	for video in response["items"]:
		if video.has("id") and video["id"].has("videoId"):
			var video_id = video["id"]["videoId"]
			fetch_video_details(video_id)
		else:
			print("Invalid video item structure")

func fetch_video_details(video_id: String):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(
		func(result, response_code, headers, body):
			if result == HTTPRequest.RESULT_SUCCESS:
				var json = JSON.new()
				var parse_result = json.parse(body.get_string_from_utf8())
				if parse_result == OK:
					var video_data = json.get_data()
					
					if video_data.has("items") and video_data["items"].size() > 0:
						var video_info = video_data["items"][0]
						if video_info.has("contentDetails"):
							var duration = video_info["contentDetails"]["duration"]
							if is_long_form_video(duration):
								create_video_entry(video_info, video_id)  # Pass video_id separately
						else:
							print("No content details found for video")
				else:
					print("Failed to parse video details JSON")
			else:
				print("Failed to fetch video details for ID: ", video_id)
	)
	
	# Construct the details URL correctly
	var details_url = "https://www.googleapis.com/youtube/v3/videos?part=contentDetails,snippet,statistics&id=" + video_id + "&key=" + API_KEY
	http_request.request(details_url)

func is_long_form_video(duration: String) -> bool:
	# Check if the video duration is longer than 60 seconds
	return duration.begins_with("PT") and int(duration.substr(2, duration.find("M") - 2)) > 0

func create_video_entry(video_data, video_id: String):  # Added video_id parameter
	# Add more robust error checking here
	if not video_data.has("snippet"):
		print("No snippet data found for video")
		return
	
	var video_panel = PanelContainer.new()
	video_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	video_panel.custom_minimum_size = Vector2(600, 100)  # Reduced height
	
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 10)
	video_panel.add_child(hbox)
	
	# Thumbnail
	var thumbnail = TextureRect.new()
	thumbnail.custom_minimum_size = Vector2(160, 90)
	thumbnail.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	thumbnail.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Play Button
	var play_button = Button.new()
	play_button.text = "Play"
	play_button.custom_minimum_size = Vector2(80, 40)
	
	# Load thumbnail
	if video_data["snippet"].has("thumbnails") and video_data["snippet"]["thumbnails"].has("medium"):
		var thumbnail_url = video_data["snippet"]["thumbnails"]["medium"]["url"]
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.request_completed.connect(
			func(result, response_code, headers, body):
				if result == HTTPRequest.RESULT_SUCCESS:
					var image = Image.new()
					var error = image.load_jpg_from_buffer(body)
					if error != OK:
						error = image.load_png_from_buffer(body)
					
					if error == OK:
						var texture = ImageTexture.create_from_image(image)
						thumbnail.texture = texture
		)
		http_request.request(thumbnail_url)
	
	# Video Information
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var title_label = Label.new()
	title_label.text = video_data["snippet"]["title"]
	title_label.max_lines_visible = 2
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	var desc_label = Label.new()
	desc_label.text = video_data["snippet"]["description"]
	desc_label.max_lines_visible = 3
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	info_vbox.add_child(title_label)
	info_vbox.add_child(desc_label)
	
	hbox.add_child(thumbnail)
	hbox.add_child(info_vbox)
	hbox.add_child(play_button)
	
	video_container.add_child(video_panel)
	
	# Connect play button to video opening method using the passed video_id
	play_button.pressed.connect(func(): play_video(video_id))

func play_video(video_id: String):
	# Open the YouTube video in the default web browser
	var youtube_url = "https://www.youtube.com/watch?v=" + video_id
	OS.shell_open(youtube_url)
	
	
	
	
