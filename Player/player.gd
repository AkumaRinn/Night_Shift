extends Node

@export var mission: PunchMission

func _ready():
	mission.mission_status = mission.MissionStatus.available
	if mission.mission_status == mission.MissionStatus.available:
		mission.start_mission()

func _process(_delta):
	print(mission.mission_status)
	print("jytdfjhty")
func _unhandled_input(_event):
	pass
