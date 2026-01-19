class_name MissionManager extends Node


var mission_lbl = MissionControl.mission_label
var curr_mission = MissionControl.current_mission
enum MissionStatus
{
	available,
	started,
	reached_goal,
	finished,
}

var mission_status: MissionStatus = MissionStatus.available
