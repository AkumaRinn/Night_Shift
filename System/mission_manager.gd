class_name MissionManager extends Node

# --- Access to MissionControl nodes ---
#@onready var mission_lbl = MissionControl.mission_label
#@onready var current_mission_text = MissionControl.current_mission
#@onready var cars_filled_count = MissionControl.cars_filled


# --- Self missions init ---
@onready var punch_in_mission: PunchMission = $PunchMission
@onready var fill_car_mission: FillCar = $FillCar
@onready var punch_out_mission: PunchOutMission = $PunchOutMission

# --- Mission split on days ---    
#Set a variable in the save Autoload or whatever that holds the current day 
#and enable the said mission set
var mission_index = 0
var day_1_missions: Array
var day_2_missions: Array
var all_missions: Array
var today_missions: Array
var current_mission
var previous_mission
var wait_interval := 2.0
var filled_cars = 0
var saved_game:SavedGame = load("user://gamesave.tres") as SavedGame
var what_is_today = 0 

enum MissionStatus {
	blocked,
	available,
	started,
	reached_goal,
	finished,
}

func _ready():
	SaveLoadAutoload.day_changed.connect(get_the_next_day)
	#If the game was saved at least once,
	#Load the day from the save file
	if FileAccess.file_exists("user://gamesave.tres"):
		what_is_today = saved_game.current_day
	#Init all possible missions and split them by days
	day_1_missions = [punch_in_mission,fill_car_mission, punch_out_mission]
	day_2_missions = [punch_in_mission,]
	all_missions = [day_1_missions, day_2_missions]

	
	today_missions = all_missions[what_is_today]
	current_mission = today_missions[mission_index]
	
	for m in today_missions:
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
	if mission_index >= today_missions.size():
		mission_index = 0
		return
	current_mission = today_missions[mission_index]
	if current_mission.mission_status == MissionStatus.available:
		current_mission.start_mission()


#Func made only for the fill cars mission 
func increment_fill_count():
	filled_cars += 1
	MissionControl.cars_filled.visible = true
	MissionControl.cars_filled.text = str(filled_cars) + "/5"
	if filled_cars == 5:
		await get_tree().create_timer(wait_interval).timeout
		MissionControl.cars_filled.visible = false
		current_mission.mission_finished()

func get_the_next_day():
	what_is_today += 1
	mission_index = 0
	today_missions = all_missions[what_is_today]
	current_mission = today_missions[mission_index]
	
	for m in today_missions:
		m.mission_manager = self
		m.mission_status = MissionStatus.available
		m.mission_started_signal.connect(_on_mission_started)
		m.mission_finished_signal.connect(_on_mission_finished)

	current_mission.start_mission()
