extends Node3D

var player_in_range := false
var is_open := false

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func toggle_door():
	if is_open:
		$AnimationPlayer.play("door_close")
	else:
		$AnimationPlayer.play("door_open")

	is_open = !is_open
	
func _unhandled_input(event):
	if player_in_range:
		pass 
		#change the cursor so he knows he can interact
	if event.is_action_pressed("interact") and player_in_range:
		if $AnimationPlayer.is_playing():
			return
		toggle_door()
