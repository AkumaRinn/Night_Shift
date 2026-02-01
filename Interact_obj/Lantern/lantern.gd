extends Node3D

var is_picked_up = false

@onready var object_body = $object_body
func on_save_game(saved_data:Array[SavedData]):
	var my_data = SavedData.new()
	my_data.position = global_position
	my_data.scene_path = scene_file_path
	my_data.should_add_to_inventory = is_picked_up
	my_data.parent_path = get_parent().get_path()
	saved_data.append(my_data)
	
func on_before_load_game():
	get_parent().remove_child(self)
	queue_free()

func on_load_game(saved_data:SavedData):
	#the check for inventory should be done here
	global_position = saved_data.position
	
