class_name  PunchMission  extends MissionManager



func start_mission() -> void:
	if mission_status == MissionStatus.available:
		mission_status = MissionStatus.started
		mission_lbl.visible = true
		curr_mission.visible = true
		curr_mission.text = "Clock in to start your shift"

#func mission_goal_reached() -> void:
#	if mission_status == MissionStatus.started:
#		mission_status = MissionStatus.reached_goal
#		mission_label.text = "Well done! Head to the BUS stop"
		
func mission_finished() -> void:
	if mission_status == MissionStatus.started:
		mission_status = MissionStatus.finished
		curr_mission.text = "You are done for today" # Just a test run.
		#Start the next mission.
