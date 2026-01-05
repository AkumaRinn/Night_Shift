extends Control


@onready var main_menu = $PausePanel
@onready var settings_menu = $SettingsMenu/SettingsPanel
@onready var sens_slider = $SettingsMenu/SettingsPanel/Sensitivity

var mouse_sensitivity: float = 0.08

func _ready():
	
	hide()
	settings_menu.hide()
	main_menu.show()

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

func escape():
	if Input.is_action_just_pressed("escape"):
		if get_tree().paused:
			resume()
		else:
			pause()


func _on_sensitivity_value_changed(value):
	Settings.mouse_sensitivity = value

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
