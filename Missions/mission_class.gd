class_name Mission extends Node

var punch_mission_flag = 0


enum MissionStatus {
	blocked,
	available,
	started,
	reached_goal,
	finished,
}

var mission_status: MissionStatus = MissionStatus.available
var mission_manager: MissionManager
signal mission_started_signal(text)
signal mission_finished_signal(text)
