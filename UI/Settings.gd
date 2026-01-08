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

func _ready():
	load_settings()

func load_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		mouse_sensitivity = config.get_value("controls", "sensitivity", 1.0)
		invert_y = config.get_value("controls", "invert_y", false)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("controls", "sensitivity", mouse_sensitivity)
	config.set_value("controls", "invert_y", invert_y)
	config.save("user://settings.cfg")
