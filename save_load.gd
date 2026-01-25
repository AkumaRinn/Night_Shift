class_name SaveLoad extends Node

@onready var player
var should_load_on_ready := false
func register_player(p):
	player = p
	if should_load_on_ready:
		load_game()
		should_load_on_ready = false

func save_game():
	if player == null:
		push_warning("SaveLoad: player not registered")
		return
		
	var saved_game:SavedGame = SavedGame.new()
	saved_game.player_position = player.position
	ResourceSaver.save(saved_game, "user://gamesave.tres")
	
func load_game():
	if player == null:
		push_warning("SaveLoad: player not registered")
		return
		
	if not FileAccess.file_exists("user://gamesave.tres"):
		return
	
	var saved_game:SavedGame = load("user://gamesave.tres") as SavedGame
	player.global_position = saved_game.player_position
