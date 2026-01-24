class_name SaveLoad extends Node

@onready var player = %player

func save_game():
	var saved_game:SavedGame = SavedGame.new()
	saved_game.player_position = player.position
	
	ResourceSaver.save(saved_game, "user://gamesave.tres")
	
func load_game():
	var saved_game:SavedGame = load("user://gamesave.tres") as SavedGame
	player.global_position = saved_game.player_position
