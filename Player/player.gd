extends Node

# Central placeholder for the Player
# Only put logic here that is NOT handled by Movement, Controller, or Stamina

func _ready():
	# Initialize anything global for the player
	pass

func _process(delta):
	# Optional per-frame logic unrelated to movement or camera
	pass

func _unhandled_input(event):
	# Optional global input not handled elsewhere
	pass
