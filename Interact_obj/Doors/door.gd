extends Node3D

var is_open := false
@onready var anim_player = $"../AnimationPlayer"

func toggle_door():
	if is_open:
		anim_player.play("door_close")
	else:
		anim_player.play("door_open")

	is_open = !is_open

func interact(_player):
	if anim_player.is_playing():
			return
	toggle_door()
	
func _unhandled_input(_event):
	pass
		
