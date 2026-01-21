class_name Mission extends Node



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
