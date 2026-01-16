extends Node3D

@export var car_scene: PackedScene
@export var car_path1: Path3D #Gas path 1
@export var car_path2: Path3D #Gas path 2
@export var car_path3: Path3D #Gas path 3
@export var car_path4: Path3D #Gas path 4
@export var car_path5: Path3D #Road path left
@export var car_path6: Path3D #Road path right
@export var spawn_interval := 3.0

@onready var car_path: Path3D  #Path selecter
var paths: Array[Path3D]

func _ready():
	car_path = car_path5 #if this shit is initialized with car_path1, everything works fine[not anymore].
	#if it is initialized with car_path5, the car that spawns in is not moving at all
	#change the way it is "called" maybe. with the await setting it off course maybe.
	paths = [car_path1, car_path5, car_path6]
	spawn_loop()

func spawn_loop():
	while true:
		spawn_car()
		await get_tree().create_timer(spawn_interval).timeout # change this shit.it goes brrr
		#see _ready()

func spawn_car():
	for child in car_path.get_children():
		if child is PathFollow3D:
			var index = randi() % paths.size()
			car_path = paths[index]
			return

	# Create path follower
	var path_follow := PathFollow3D.new()
	car_path.add_child(path_follow)


	# Spawn car UNDER the PathFollow
	var car = car_scene.instantiate()
	path_follow.add_child(car)
	car.path_follow = path_follow
