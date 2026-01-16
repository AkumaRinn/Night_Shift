extends Node3D

const CAR_SPEED := 10

@onready var path_follow := get_parent() as PathFollow3D
@onready var stop_sensor: Area3D = $StopSensor

var is_moving := true
var is_waiting_for_player := false
var is_activated := false



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


		
	if path_follow.progress_ratio >= 0.9:
		path_follow.queue_free()
		queue_free()


func _on_stop_sensor_area_entered(area):
	if area.is_in_group("car_stop") and not self.is_activated:
		is_moving = false
		is_waiting_for_player = true
