class_name MissionManager extends Node

# --- Access to MissionControl nodes ---
var mission_lbl = MissionControl.mission_label
var current_mission_text = MissionControl.current_mission
var cars_filled_count = MissionControl.cars_filled


# --- Self missions init ---
@onready var punch_in_mission: PunchMission = $PunchMission
@onready var fill_car_mission: FillCar = $FillCar

# --- Mission split on days ---    
#Set a variable in the save Autoload or whatever that holds the current day 
#and enable the said mission set
var mission_index = 0
var day_1_missions: Array
var current_mission

enum MissionStatus
{
	blocked,
	available,
	started,
	reached_goal,
	finished,
}

# --- Missions status init---
var punch_mission_status: MissionStatus = MissionStatus.available
var fill_car_mission_status: MissionStatus = MissionStatus.blocked

func _ready():
	day_1_missions = [punch_in_mission,fill_car_mission]
	current_mission = day_1_missions[mission_index]
