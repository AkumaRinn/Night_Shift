extends CharacterBody3D

@export var navigation_region: NavigationRegion3D
@export var player: CharacterBody3D
@onready var navigation_agent: NavigationAgent3D = $SalteNavigationAgent
@onready var patrolTimer: Timer = $PatrolTimer
@onready var salteEyes = $SalteEyes

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
var salte_chase_speed: int = 7
var vision_mask = (1 << 0) | (1 << 2)


#Player detection bools
var playerInCloseHearing: bool
var playerInFarHearing: bool
var playerInCloseSight: bool
var playerInFarSight: bool

func _ready():
	currentState = States.patrol
	waypoints = get_tree().get_nodes_in_group("salte_waypoint")
	navigation_agent.target_position = waypoints[waypointIndex].global_position


func _process(delta):
	match currentState:
		States.patrol:
			patrol(salte_speed, delta)
		States.chasing:
			chase(salte_chase_speed, delta)
		States.hunting:
			hunt(salte_speed, delta)
		States.waiting:
			pass


#--- SAL-TE Actions ---#

func patrol(speed: int, delta):
	if navigation_agent.is_navigation_finished():
		currentState = States.waiting
		patrolTimer.start()
		return
	else:
		move_to_target(speed, delta)

func chase(speed: int, delta):
	patrolTimer.stop()
	navigation_agent.target_position = player.global_position
	move_to_target(speed, delta)


func hunt(speed: int, delta):
	if navigation_agent.is_navigation_finished():
		currentState = States.waiting
		patrolTimer.start()
	move_to_target(speed, delta)


func wait():
	#do some animation to look around maybe 
	pass


#--- Helper Functions ---#
func _on_patrol_timer_timeout():
	currentState = States.patrol
	waypointIndex += 1
	if waypointIndex >= waypoints.size():
		waypointIndex = 0
	navigation_agent.target_position = waypoints[waypointIndex].global_position

func face_direction(delta,_direction : Vector3):
	rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10)

func check_for_player():
	# --- HEARING: always works ---
	if playerInCloseHearing or playerInFarHearing:
		currentState = States.hunting
		navigation_agent.target_position = player.global_position

	# --- VISION: line of sight required ---
	if playerInCloseSight or playerInFarSight:
		var spaceState = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.new()
		query.from = salteEyes.global_position
		query.to = player.global_position
		query.exclude = [self]
		query.collision_mask = vision_mask

		var result = spaceState.intersect_ray(query)
		if result:
			var hit_owner = result["collider"].get_owner()
			if hit_owner == player:
				currentState = States.chasing
				navigation_agent.target_position = player.global_position




func move_to_target(speed, delta):
	var targetPos = navigation_agent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	velocity = direction * speed
	face_direction(delta, direction)
	move_and_slide()
	if playerInFarHearing:
		check_for_player()
	



#--- SAL-TE Hearing ---#

#Far Hearing
func _on_hearing_far_body_entered(body):
	if body.is_in_group("player"):
		playerInFarHearing = true
		print("Player is nearby")


func _on_hearing_far_body_exited(body):
	if body.is_in_group("player"):
		playerInFarHearing = false
		print("I lost player")


#Close Hearing
func _on_hearing_close_body_entered(body):
	if body.is_in_group("player"):
		playerInCloseHearing = true
		print("Player very close")


func _on_hearing_close_body_exited(body):
	if body.is_in_group("player"):
		playerInCloseHearing = false
		print("Player is leaving")


#--- SAL-TE Vision ---#

#Close Vision
func _on_sight_close_body_entered(body):
	if body.is_in_group("player"):
		playerInCloseSight = true
		print("I found player")


func _on_sight_close_body_exited(body):
	if body.is_in_group("player"):
		playerInCloseSight = false
		print("Player is running")


#Far Vision
func _on_sight_far_body_entered(body):
	if body.is_in_group("player"):
		playerInFarSight = true
		print("Is that the player?")


func _on_sight_far_body_exited(body):
	if body.is_in_group("player"):
		playerInFarSight = false
		print("Must have been the wind")
