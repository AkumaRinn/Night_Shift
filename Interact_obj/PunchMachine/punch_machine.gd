extends Node3D

var mission

func interact(player):
	mission = player.player_mission
	mission.mission_finished()
