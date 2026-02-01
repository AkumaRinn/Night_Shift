class_name PunchOutMission extends Mission

func start_mission() -> void:
	punch_mission_flag = 1
	if mission_status == MissionStatus.available:
		mission_status = MissionStatus.started
		emit_signal("mission_started_signal", "Clock out. You are done for today")

func mission_finished() -> void:
	if mission_status == MissionStatus.started:
		mission_status = MissionStatus.finished
		emit_signal("mission_finished_signal", "Head to the bus")
		SaveLoadAutoload.day_pass()
