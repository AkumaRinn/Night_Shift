class_name SaveLoad extends Node

@onready var player
@onready var controller

@onready var game_day = 0
@onready var mission_index_save
signal day_changed

var should_load_on_ready := false
func register_player(p, c):
	player = p
	controller = c
	if should_load_on_ready:
		load_game()
		should_load_on_ready = false

func save_game():
	#Check if the player node is registered aka if the game was played at least once 
	if player == null:
		push_warning("SaveLoad: player not registered")
		return
	
	var saved_game:SavedGame = SavedGame.new()
	var saved_data:Array[SavedData] = []
	
	#Call the save_game function for all the objects that are supposed to be saved
	get_tree().call_group("game_event", "on_save_game", saved_data)
	get_tree().call_group("game_event", "on_save_game_no_arg")
	#Save the data inside the game save file
	saved_game.current_day = game_day
	saved_game.mission_index_saved = mission_index_save
	saved_game.player_position = player.position
	saved_game.player_rotation = player.rotation
	saved_game.camera_rotation = controller.camera.rotation
	saved_game.saved_data = saved_data
	ResourceSaver.save(saved_game, "user://gamesave.tres")
	
func load_game():
	#Load the data from the saved file
	var saved_game:SavedGame = load("user://gamesave.tres") as SavedGame
	#Error handling
	if player == null:
		push_warning("SaveLoad: player not registered")
		return
	#Check if there is any save file 
	if not FileAccess.file_exists("user://gamesave.tres"):
		return
	
	
	get_tree().call_group("game_event", "on_before_load_game")
	player.global_position = saved_game.player_position
	player.rotation = saved_game.player_rotation
	game_day = saved_game.current_day
	controller.camera.rotation = saved_game.camera_rotation
	
	for item in saved_game.saved_data:
		#Load the object itself
		var scene = load(item.scene_path) as PackedScene 
		#Instantiate the object
		var restored_node = scene.instantiate()
		var parent_node = get_tree().root.get_node(item.parent_path)

		parent_node.add_child(restored_node)
		if item.should_add_to_inventory:
			controller.add_to_inventory(restored_node)
		
		#Let the object set its own parameters
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(item)
			

func day_pass():
	game_day += 1
	mission_index_save = 0
	emit_signal("day_changed")
	save_game()


	
