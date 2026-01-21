class_name MissionManager extends Node

# --- Access to MissionControl nodes ---
#@onready var mission_lbl = MissionControl.mission_label
#@onready var current_mission_text = MissionControl.current_mission
#@onready var cars_filled_count = MissionControl.cars_filled


# --- Self missions init ---
@onready var punch_in_mission: PunchMission = $PunchMission
@onready var fill_car_mission: FillCar = $FillCar

# --- Mission split on days ---    
#Set a variable in the save Autoload or whatever that holds the current day 
#and enable the said mission set
var mission_index = 0
var day_1_missions: Array
var current_mission
var previous_mission
var wait_interval := 2.0

enum MissionStatus {
	blocked,
	available,
	started,
	reached_goal,
	finished,
}

func _ready():
	
	day_1_missions = [punch_in_mission,fill_car_mission]
	current_mission = day_1_missions[mission_index]
	for m in day_1_missions:
		m.mission_manager = self
		m.mission_started_signal.connect(_on_mission_started)
		m.mission_finished_signal.connect(_on_mission_finished)

	current_mission.start_mission()

func _on_mission_started(text):
	MissionControl.mission_label.visible = true
	MissionControl.current_mission.visible = true
	MissionControl.current_mission.text = text

func _on_mission_finished(text):
	MissionControl.current_mission.text = text
	await get_tree().create_timer(wait_interval).timeout
	start_next_mission()
	
func start_next_mission():
	previous_mission = current_mission
	previous_mission.mission_status = MissionStatus.blocked
	mission_index += 1
	current_mission = day_1_missions[mission_index]
	if current_mission.mission_status == MissionStatus.available:
		current_mission.start_mission()
