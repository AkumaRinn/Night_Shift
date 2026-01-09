extends Control


@onready var back_button = $SettingsPanel/back
@onready var sens_slider = $SettingsPanel/Sensitivity
@onready var invert_y = $SettingsPanel/InvertY

signal closed

func _ready():
	_load_settings_ui()
	var settings_nodes = get_tree().get_nodes_in_group("settings")
	if settings_nodes.size() > 0:
		return settings_nodes[0]
	
	return null


func _process(_delta):
	pass

func _load_settings_ui():
	var settings_node = _get_settings_node()
	if settings_node:
		sens_slider.value = settings_node.mouse_sensitivity
		if invert_y:
			invert_y.button_pressed = settings_node.invert_y
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


func _on_back_pressed():
	emit_signal("closed")
	queue_free()


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


func _on_resolutions_item_selected(index):
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(1280,720))
		2:
			DisplayServer.window_set_size(Vector2i(1366,768))
		3:
			DisplayServer.window_set_size(Vector2i(1440,900))
		4:
			DisplayServer.window_set_size(Vector2i(2560,1440))
		5:
			DisplayServer.window_set_size(Vector2i(3840,2160))
