extends RigidBody3D

const CAR_SPEED := 10

@onready var path_follow := get_parent().find_parent("PathFollow3D")
var is_moving := true
var is_waiting_for_player := false
var is_activated := false
var stop_point = 93.5 #change later with collision detection on destination point



func _ready():
	pass # Replace with function body.

func interact(_player):
	if not is_waiting_for_player:
		return
	is_activated = true
	is_waiting_for_player = false
	is_moving = true
	

func _process(delta):
	if is_moving:
		path_follow.progress += CAR_SPEED * delta
		
		if (path_follow.progress >= stop_point) && !is_activated:
			is_moving = false
			is_waiting_for_player = true
			
	if path_follow.get_progress_ratio() >= 1:
		queue_free()
