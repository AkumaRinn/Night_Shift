class_name FillCar extends MissionManager


func start_mission() -> void:
	if fill_car_mission_status == MissionStatus.available:
		fill_car_mission_status = MissionStatus.started
		mission_lbl.visible = true
		current_mission_text.visible = true
		cars_filled_count.visible = true
		current_mission_text.text = "Fill the tank of 5 cars"

#func mission_goal_reached() -> void:
#	if mission_status == MissionStatus.started:
#		mission_status = MissionStatus.reached_goal
#		mission_label.text = "Well done! Head to the BUS stop"
		
func mission_finished() -> void:
	if fill_car_mission_status == MissionStatus.started:
		fill_car_mission_status = MissionStatus.finished
		cars_filled_count.text = ""
		cars_filled_count.visible = false
		current_mission_text.text = "Punch out for today" # Just a test run.
		#Start the next mission.
