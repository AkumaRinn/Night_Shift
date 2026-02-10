extends CharacterBody3D

@export var navigation_region: NavigationRegion3D
@export var player: CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $SalteNavigationAgent
@onready var patrolTimer: Timer = $PatrolTimer
@onready var salteEyes = $SalteEyes
@onready var trackTimer = $TrackTimer
@onready var enterSceneTrack = $PatrolMusicEnterScene
@onready var vrxBody = $VRX_Import
@onready var vrxAnimation = vrxBody.get_node("AnimationPlayer")



var trackSelecter: Array = [0,0,0,0]

enum States{
	patrol,
	chasing,
	hunting,
	waiting
}

var currentState: States
var previousState: States
var waypoints: Array
var waypointIndex: int = 0
var salte_speed: int = 5
var salte_chase_speed: int = 7
var vision_mask = (1 << 0) | (1 << 2)
var queued_animation: String = ""


#Player detection bools
var playerInCloseHearing: bool
var playerInFarHearing: bool
var playerInCloseSight: bool
var playerInFarSight: bool

func _ready():
	enterSceneTrack.start()
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
			wait()
	change_track()
	previousState = currentState


#--- SAL-TE Actions ---#

func patrol(speed: int, delta):
	
	vrxAnimation.play("Walk")
	if navigation_agent.is_navigation_finished():
		currentState = States.waiting
		patrolTimer.start()
		return
	else:
		move_to_target(speed, delta)

func chase(speed: int, delta):
	vrxAnimation.play("RunOpen")
	patrolTimer.stop()
	navigation_agent.target_position = player.global_position
	move_to_target(speed, delta)


func hunt(speed: int, delta): #Looking for player
	if navigation_agent.is_navigation_finished():
		currentState = States.waiting
		patrolTimer.start()
	move_to_target(speed, delta)


func wait():
	#Remake the looking around animation into one 
	vrxAnimation.play("LookLeft")



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
			var hit_owner = result["collider"]#.get_owner()
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
	if playerInCloseSight:
		check_for_player()

func change_track():
	if currentState != previousState:
		#Don't change track if SAL-TE is going from patrol to waiting and vice versa
		if (currentState == States.patrol && previousState == States.waiting) || (currentState == States.waiting && previousState == States.patrol):
			return
		trackTimer.start()
		trackSelecter[currentState] = 1

func _on_track_timer_timeout():
	#Select the track
	if trackSelecter[1]:
		#Stop other tracks and Play chasing music
		AudioManager.saltePatrolMusic.stop()
	elif trackSelecter[2]:
		#Stop other tracks and Play hunting music
		AudioManager.saltePatrolMusic.stop()
	else:
		#Play patrol/waiting music
		AudioManager.saltePatrolMusic.play()
	#Reset the selecter
	trackSelecter = [0,0,0,0]

#--- SAL-TE Hearing ---#

#Far Hearing
func _on_hearing_far_body_entered(body):
	if body.is_in_group("player"):
		playerInFarHearing = true


func _on_hearing_far_body_exited(body):
	if body.is_in_group("player"):
		playerInFarHearing = false


#Close Hearing
func _on_hearing_close_body_entered(body):
	if body.is_in_group("player"):
		playerInCloseHearing = true


func _on_hearing_close_body_exited(body):
	if body.is_in_group("player"):
		playerInCloseHearing = false


#--- SAL-TE Vision ---#

#Close Vision
func _on_sight_close_body_entered(body):
	if body.is_in_group("player"):
		playerInCloseSight = true


func _on_sight_close_body_exited(body):
	if body.is_in_group("player"):
		playerInCloseSight = false


#Far Vision
func _on_sight_far_body_entered(body):
	if body.is_in_group("player"):
		playerInFarSight = true


func _on_sight_far_body_exited(body):
	if body.is_in_group("player"):
		playerInFarSight = false


func _on_patrol_music_enter_scene_timeout():
	AudioManager.saltePatrolMusic.play()
