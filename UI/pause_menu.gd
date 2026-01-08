# res://UI/pause_menu.gd
extends Control

@onready var main_menu = $PausePanel
@onready var settings_menu = $SettingsMenu
@onready var sens_slider = $SettingsMenu/SettingsPanel/Sensitivity
@onready var invert_checkbox = $SettingsMenu/SettingsPanel/InvertY

var mouse_sensitivity: float = 0.08

func _ready():
	hide()
	settings_menu.hide()
	main_menu.show()
	_load_settings_ui()

func _load_settings_ui():
	var settings_node = _get_settings_node()
	if settings_node:
		sens_slider.value = settings_node.mouse_sensitivity
		if invert_checkbox:
			invert_checkbox.button_pressed = settings_node.invert_y
	else:
		sens_slider.value = 0.08

func _get_settings_node() -> Node:
	if has_node("/root/Settings"):
		return get_node("/root/Settings")
	elif get_tree().root.has_node("Settings"):
		return get_tree().root.get_node("Settings")
	
	var settings_nodes = get_tree().get_nodes_in_group("settings")
	if settings_nodes.size() > 0:
		return settings_nodes[0]
	
	return null

func resume():
	get_tree().paused = false
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pause():
	get_tree().paused = true
	show()
	main_menu.show()
	settings_menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_load_settings_ui()

func escape():
	if Input.is_action_just_pressed("escape"):
		if get_tree().paused:
			resume()
		else:
			pause()

func _on_sensitivity_value_changed(value):
	var settings_node = _get_settings_node()
	if settings_node:
		settings_node.mouse_sensitivity = value
		if settings_node.has_method("save_settings"):
			settings_node.save_settings()

func _on_invert_y_toggled(button_pressed):
	var settings_node = _get_settings_node()
	if settings_node:
		settings_node.invert_y = button_pressed
		if settings_node.has_method("save_settings"):
			settings_node.save_settings()

func _on_resume_button_pressed():
	resume()

func _on_options_button_pressed():
	main_menu.hide()
	settings_menu.show()

func _on_back_pressed():
	settings_menu.hide()
	main_menu.show()

func _on_exit_button_pressed():
	get_tree().quit()

func _process(_delta):
	escape()
