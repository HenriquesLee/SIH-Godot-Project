extends Node

var language: String = "English"  # Default language

func set_language(new_language: String):
	language = new_language
	print(language)
