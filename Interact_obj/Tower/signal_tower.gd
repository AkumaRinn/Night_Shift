extends Node3D

@onready var ladderBody: Area3D = $Ladder
@onready var bottomMarker = $BottomMarker
@onready var topMarker = $TopMarker
@onready var towerNode = $"."

func _on_ladder_body_entered(body):
	if body.is_in_group("player"):
		body.current_ladder = ladderBody
		body.signalTower = towerNode


func _on_ladder_body_exited(body):
	if body.is_in_group("player"):
		if body.current_ladder == ladderBody:
			body.current_ladder = null
			body.signalTower = null
	
