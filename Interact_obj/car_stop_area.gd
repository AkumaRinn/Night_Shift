extends Area3D


func _ready():
	pass

func _on_body_entered(body):
	if body.is_in_group("car"):
		body.is_moving = false
		body.is_waiting_for_player = true
