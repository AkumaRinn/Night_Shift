class_name  PunchMission  extends Mission

func start_mission() -> void:
	if mission_status == MissionStatus.available:
		mission_status = MissionStatus.started
		emit_signal("mission_started_signal", "Clock in to start your shift")

func mission_finished() -> void:
	if mission_status == MissionStatus.started:
		mission_status = MissionStatus.finished
		emit_signal("mission_finished_signal", "I wish you'll have an easy shift!")
		
