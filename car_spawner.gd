extends Node3D

@export var car_scene: PackedScene
@export var car_path: Path3D
@export var spawn_interval := 8.0

func _ready():
	spawn_loop()

func spawn_loop():
	while true:
		spawn_car()
		await get_tree().create_timer(spawn_interval).timeout

func spawn_car():
	if car_path.get_child_count() > 0:
		return
	# Create path follower
	var path_follow := PathFollow3D.new()
	car_path.add_child(path_follow)


	# Spawn car UNDER the PathFollow
	var car = car_scene.instantiate()
	path_follow.add_child(car)
	path_follow.rotation_degrees = Vector3(0, 180, 0)
	path_follow.rotation = Vector3(90,0,0)
	var car_body = car.get_node("Car")
	car_body.path_follow = path_follow
