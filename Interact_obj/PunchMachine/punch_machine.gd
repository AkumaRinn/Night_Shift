extends Node3D

var mission

func interact(player):
	mission = player.player_mission
	if mission.punch_mission_flag == 1:
		mission.mission_finished()
