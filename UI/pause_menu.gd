# res://UI/pause_menu.gd
extends Control

@onready var main_menu = $PausePanel

@export var settings_scene: PackedScene
var settings_instance: Control = null
var mouse_sensitivity: float = 0.08

func _ready():
	hide()
	main_menu.show()

func resume():
	get_tree().paused = false
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pause():
	get_tree().paused = true
	show()
	main_menu.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func escape():
	if settings_instance:
		return
	if Input.is_action_just_pressed("escape"):
		if get_tree().paused:
			resume()
		else:
			pause()

func _on_resume_button_pressed():
	resume()

func _on_options_button_pressed():
	if settings_instance:
		return  # already open
	settings_instance = settings_scene.instantiate()
	settings_instance.connect("closed", Callable(self, "_on_settings_closed"))
	get_tree().root.add_child(settings_instance)
	hide()
	main_menu.hide()
	
func _on_settings_closed():
	settings_instance = null
	show()
	main_menu.show()

func _on_exit_button_pressed():
	get_tree().quit()

func _process(_delta):
	escape()
