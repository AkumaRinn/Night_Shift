# res://UI/settings.gd
extends Node

# Mouse sensitivity multiplier (0.1 = 10%, 1.0 = 100%, 5.0 = 500%)
var mouse_sensitivity: float = 1.0:
	set(value):
		mouse_sensitivity = clamp(value, 0.1, 5.0)  # Limit range
		save_settings()

var invert_y: bool = false:
	set(value):
		invert_y = value
		save_settings()



var resolution: Vector2i:
	get:
		return resolution
	set(value):
		resolution = value
		apply_resolution()
		save_settings()

func _ready():
	load_settings()
	apply_resolution()

func apply_resolution():
	DisplayServer.window_set_size(resolution)


func load_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		mouse_sensitivity = config.get_value("controls", "sensitivity", 1.0)
		invert_y = config.get_value("controls", "invert_y", false)
		var w = config.get_value("video", "width", 1920)
		var h = config.get_value("video", "height", 1080)
		resolution = Vector2i(w, h)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("controls", "sensitivity", mouse_sensitivity)
	config.set_value("controls", "invert_y", invert_y)
	config.set_value("video", "width", resolution.x)
	config.set_value("video", "height", resolution.y)
	
	config.save("user://settings.cfg")
