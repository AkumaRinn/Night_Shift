extends CharacterBody3D

@export var navigation_region: NavigationRegion3D
@export var player: CharacterBody3D
@onready var navigation_agent: NavigationAgent3D = $SalteNavigationAgent
@onready var patrolTimer: Timer = $PatrolTimer

enum States{
	patrol,
	chasing,
	hunting,
	waiting
}

var currentState: States
var waypoints: Array
var waypointIndex: int = 0
var salte_speed: int = 5

func _ready():
	currentState = States.patrol
	waypoints = get_tree().get_nodes_in_group("salte_waypoint")
	navigation_agent.target_position = waypoints[waypointIndex].global_position


func _process(delta):
	match currentState:
		States.patrol:
			if navigation_agent.is_navigation_finished():
				currentState = States.waiting
				patrolTimer.start()
				return
			else:
				patrol(salte_speed, delta)
			
		States.chasing:
			pass
		States.hunting:
			pass
		States.waiting:
			pass

func patrol(speed: int, _delta):
	var targetPos = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	velocity = direction * speed
	move_and_slide()

func chase():
	pass


func hunt():
	pass


func wait():
	pass


func _on_patrol_timer_timeout():
	currentState = States.patrol
	waypointIndex += 1
	print(waypoints.size())
	if waypointIndex >= waypoints.size():
		waypointIndex = 0
	navigation_agent.target_position = waypoints[waypointIndex].global_position
