extends Node3D

@onready var mission: PunchMission

func interact(player):
	mission = player.mission
	mission.mission_finished()
