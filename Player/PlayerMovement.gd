extends CharacterBody3D

# --- Movement Constants ---
const SPEED = 4.5
const JUMP_VELOCITY = 10
const GRAVITY = 44.1

# --- Speed Multipliers ---
const BACKWARD_MULTIPLIER = 0.6
const STRAFE_MULTIPLIER = 0.6
const CROUCH_MULTIPLIER = 0.45

# --- Crouch ---
var is_crouching: bool = false

# --- Collider references ---
@onready var collider: CollisionShape3D = $CollisionShape3D
var original_collider_height: float
var crouch_collider_height: float = 1.2
var original_collider_y: float
var crouch_collider_y: float

# --- Camera Reference ---
@onready var camera: Camera3D = $Camera3D
@onready var stamina_component = $Stamina

# --- Phone Elements --- #
@onready var phone = $PlayerCanvas/PhoneUI
@onready var playerCanvas = $PlayerCanvas
@onready var reportPage = $PlayerCanvas/PhoneUI/ReportPage
@onready var logsPage = $PlayerCanvas/PhoneUI/LogsPage
@onready var mainPage = $PlayerCanvas/PhoneUI/MainPage
@onready var backFromReport = $PlayerCanvas/PhoneUI/ReportPage/BackReport
@onready var anomaliesList = $PlayerCanvas/PhoneUI/ReportPage/AnomalyObjects/VBoxContainer
@onready var anomalyDetails = $PlayerCanvas/PhoneUI/ReportPage/AnomalyDetails

@onready var logsList = $PlayerCanvas/PhoneUI/LogsPage/ScrollContainer/LogsList
var log_scene = preload("res://Player/LogEntry.tscn")


# --- Movement toggle States --- #
enum PlayerState {
	NORMAL,
	CLIMBING,
	PHONE
}
var playerState: PlayerState = PlayerState.NORMAL
var current_ladder: Area3D = null
var signalTower = null
@export var climb_speed := 3.0
@onready var can_move: bool = true

func _ready():
	if collider and collider.shape is CapsuleShape3D:
		var shape = collider.shape as CapsuleShape3D
		original_collider_height = shape.height
		original_collider_y = collider.transform.origin.y
		crouch_collider_y = original_collider_y - (original_collider_height - crouch_collider_height)/2

func _physics_process(delta):
	
	if can_move:
		match playerState:
			PlayerState.NORMAL:
				handle_normal_movement(delta)
			PlayerState.CLIMBING:
				handle_climbing(delta)
	
func _input(event):
	if event.is_action_pressed("toggle_phone"):
		if playerState == PlayerState.NORMAL:
			open_phone()
		else:
			close_phone()



func handle_normal_movement(delta):
	# --- Crouch input ---
	var crouch_pressed = Input.is_action_pressed("crouch")
	set_crouch(crouch_pressed)

	# --- Notify camera ---
	if camera and camera.has_method("set_crouch"):
		camera.set_crouch(is_crouching)

	# --- Adjust collider smoothly ---
	if collider and collider.shape is CapsuleShape3D:
		var shape = collider.shape as CapsuleShape3D
		var target_height = crouch_collider_height if is_crouching else original_collider_height
		shape.height = lerp(shape.height, target_height, 10.0 * delta)
		var target_y = crouch_collider_y if is_crouching else original_collider_y
		collider.transform.origin.y = lerp(collider.transform.origin.y, target_y, 10.0 * delta)

	# --- Input ---
	var input_dir = Input.get_vector(
		"left_walk",
		"right_walk",
		"forward_walk",
		"backwards_walk"
	)

	# --- Speed multiplier ---
	var speed_multiplier := 1.0
	if Input.is_action_pressed("forward_walk"):
		speed_multiplier = 1.0
	elif Input.is_action_pressed("backwards_walk"):
		speed_multiplier = BACKWARD_MULTIPLIER
	elif Input.is_action_pressed("left_walk") or Input.is_action_pressed("right_walk"):
		speed_multiplier = STRAFE_MULTIPLIER
	if is_crouching:
		speed_multiplier *= CROUCH_MULTIPLIER

	# --- Convert to world direction ---
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# --- Gravity ---
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif velocity.y < 0:
		velocity.y = 0

	# --- Jump (disabled while crouching) ---
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY

	# --- Sprint ---
	var base_speed = SPEED
	var can_sprint = not is_crouching and direction.length() > 0
	if stamina_component:
		base_speed *= stamina_component.update(
			delta,
			Input.is_action_pressed("sprint") and can_sprint,
			can_sprint
		)

	var final_speed = base_speed * speed_multiplier

	# --- Apply movement ---
	if direction.length() > 0:
		velocity.x = direction.x * final_speed
		velocity.z = direction.z * final_speed
		if AudioManager.steps_sound.is_playing():
			pass
		else:
			AudioManager.steps_sound.play()
	else:
		var decel = SPEED * 10 * delta
		velocity.x = move_toward(velocity.x, 0, decel)
		velocity.z = move_toward(velocity.z, 0, decel)
		AudioManager.steps_sound.stop()

	move_and_slide()

	# --- Camera bobbing ---
	if camera and camera.has_method("apply_bob"):
		camera.apply_bob(direction, delta)
	
	# Try to grab ladder
	if current_ladder and Input.is_action_pressed("forward_walk"):
		if is_near_ladder_bottom():
			enter_climbing()
	
	if current_ladder and Input.is_action_pressed("forward_walk"):
		if is_near_ladder_top():
			enter_climbing()

# --- Crouch setter ---
func set_crouch(state: bool) -> void:
	is_crouching = state



# --- Ladder climbing state functions --- #
func enter_climbing():
	playerState = PlayerState.CLIMBING
	velocity = Vector3.ZERO
	#set_gravity_scale(0)
	
func exit_climbing():
	playerState = PlayerState.NORMAL
	#set_gravity_scale(1)

func is_near_ladder_bottom() -> bool:
	var bottom = signalTower.bottomMarker.global_position
	return global_position.distance_to(bottom) < 0.6
	
func is_near_ladder_top() -> bool:
	var top = signalTower.topMarker.global_position
	return global_position.distance_to(top) < 0.6

func handle_climbing(_delta):
	var input := Input.get_axis("backwards_walk", "forward_walk")

	# Move straight up/down
	velocity = Vector3.UP * input * climb_speed

	# Exit conditions
	if Input.is_action_just_pressed("jump"):
		exit_climbing()
	if not current_ladder:
		exit_climbing()

	if current_ladder:
		if is_near_ladder_bottom() and Input.is_action_pressed("backwards_walk"):
			exit_climbing()
		
	
	# Lock X/Z to ladder
	if current_ladder:
		var ladder_pos = current_ladder.global_position
		global_position.x = ladder_pos.x
		global_position.z = ladder_pos.z

	move_and_slide()


# --- Phone system usability --- #
func open_phone():
	playerState = PlayerState.PHONE
	# Show phone visually
	phone.visible = true
	#create_tween().tween_property(phone, "position:y", -0.1, 0.2)
	# Disable player movement
	can_move = false
	# Switch mouse mode
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func close_phone():
	playerState = PlayerState.NORMAL
	# this tween not visible, just resets the position cause i don't wnat to wait here
	#create_tween().tween_property(phone, "position:y", 0.2, -0.1)
	phone.visible = false
	can_move = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# --- Phone Logic --- #
func _on_report_tab_button_pressed():
	mainPage.visible = false
	reportPage.visible = true

func _on_back_report_pressed():
	reportPage.visible = false
	mainPage.visible = true


func _on_logs_back_button_pressed():
	logsPage.visible = false
	mainPage.visible = true


func _on_logs_tab_button_pressed():
	mainPage.visible = false
	logsPage.visible = true
	


func _on_log_button_pressed():
	#save the input and load them in the log page
	var selectedAnomaly = get_selected_anomaly(anomaliesList)
	print(selectedAnomaly)
	var justificationInput = anomalyDetails.text
	print(justificationInput)
	if selectedAnomaly == null:
		return
	# Append data to the logged anomalies array that needs to be saved
	# Update the log page
	add_entry(selectedAnomaly, justificationInput)
	# Clear the logging page
	for button in anomaliesList.get_children():
		if button is Button and button.button_pressed:
			button.button_pressed = false
	anomalyDetails.text = ""
	


# --- helper Functions --- #

func get_selected_anomaly(vbox : VBoxContainer):
	for button in vbox.get_children():
		if button.button_pressed:
			return button.text
			
func add_entry(anomaly_name: String, anomaly_description: String):
	var instance = log_scene.instantiate()

	instance.get_node("HBoxContainer/EntryTitle").text = anomaly_name + str(": ")
	instance.get_node("HBoxContainer/EntryText").text = anomaly_description
	
	logsList.add_child(instance)
