extends Node3D

@onready var save_load:SaveLoad = $SaveLoad

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = FileAccess.open("user://gamesave.tres",FileAccess.READ)
	if file:
		file.close()
		save_load.load_game()
