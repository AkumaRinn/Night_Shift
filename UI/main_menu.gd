extends Control


@onready var settings_instance: Control = null
@export var settings_scene: PackedScene


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://level_00.tscn")


func _on_load_button_pressed():
	pass # Replace with function body.


func _on_settings_button_pressed():
	if settings_instance:
		return  # already open
	settings_instance = settings_scene.instantiate()
	settings_instance.connect("closed", Callable(self, "_on_settings_closed"))
	get_tree().root.add_child(settings_instance)
	
func _on_settings_closed():
	settings_instance = null

func _on_exit_button_pressed():
	get_tree().quit()
