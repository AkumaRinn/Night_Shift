extends Node3D

const CAR_SPEED := 10

@onready var path_follow: PathFollow3D = null
@onready var stop_sensor: Area3D = $StopSensor

var is_moving := true
var is_waiting_for_player := false
var is_activated := false
var stop_point = 93.5 #change later with collision detection on destination point



func _ready():
	pass

func interact(player):
	if not is_waiting_for_player:
		return
	#increment the fill bar on the player UI.
	if player.fill_progress.value >= 100:
		is_activated = true
		is_waiting_for_player = false
		is_moving = true
		player.fill_progress.value = 0
	

func _physics_process(delta):
	
	if not path_follow:
		return

	if is_moving and !is_waiting_for_player:
		path_follow.progress += CAR_SPEED * delta
		global_transform = path_follow.global_transform
		if (path_follow.progress >= stop_point) && !is_activated: # change it so it stops if it hits a stop collider
			is_moving = false
			is_waiting_for_player = true
			
		
	if path_follow.progress_ratio >= 0.9:
		path_follow.queue_free()
		queue_free()
