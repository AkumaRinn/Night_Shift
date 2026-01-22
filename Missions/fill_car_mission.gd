class_name FillCar extends Mission


func start_mission() -> void:
	if mission_status == MissionStatus.available:
		mission_status = MissionStatus.started
		emit_signal("mission_started_signal", "Fill in 5 cars")

func mission_finished() -> void:
	if mission_status == MissionStatus.started:
		mission_status = MissionStatus.finished
		emit_signal("mission_finished_signal", "You are done for today")

func increment_count() -> void:
	mission_manager.increment_fill_count()
