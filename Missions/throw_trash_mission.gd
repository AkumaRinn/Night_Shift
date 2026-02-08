class_name ThrowTrash extends Mission


func start_mission() -> void:
	if mission_status == MissionStatus.available:
		mission_status = MissionStatus.started
		emit_signal("mission_started_signal", "Throw out the trash")

func mission_finished() -> void:
	if mission_status == MissionStatus.started:
		mission_status = MissionStatus.finished
		emit_signal("mission_finished_signal", "Never gonna give you up")
