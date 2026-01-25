extends Control


@onready var main_settings_instance: Control = null
@export var settings_scene: PackedScene


func _process(_delta):
	pass


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://level_00.tscn")


func _on_load_button_pressed():
	if FileAccess.file_exists("user://gamesave.tres"):
		SaveLoadAutoload.should_load_on_ready = true
		get_tree().change_scene_to_file("res://level_00.tscn")
	else:
		pass
		#give the user feedback that there is no saved game yet


func _on_settings_button_pressed():
	if main_settings_instance:
		return  # already open
	main_settings_instance = settings_scene.instantiate()
	main_settings_instance.connect("closed", Callable(self, "_on_settings_closed"))
	get_tree().root.add_child(main_settings_instance)
	
func _on_settings_closed():
	main_settings_instance = null

func _on_exit_button_pressed():
	get_tree().quit()
