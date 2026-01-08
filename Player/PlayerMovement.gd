# res://Player/PlayerMovement.gd
extends CharacterBody3D

# --- Movement Constants ---
const SPEED = 4.5
const JUMP_VELOCITY = 9
const GRAVITY = 44.1

# --- Speed Multipliers ---
const BACKWARD_MULTIPLIER = 0.6    # S key slower
const STRAFE_MULTIPLIER = 0.6      # A/D keys slower

# --- Camera Reference ---
@onready var camera = $Camera3D
@onready var stamina_component = $Stamina

func _physics_process(delta):
	# --- Input ---
	var input_dir = Input.get_vector("left_walk", "right_walk", "forward_walk", "backwards_walk")
	
	# Determine speed multiplier based on input
	var speed_multiplier = 1.0
	
	if Input.is_action_pressed("forward_walk"):
		speed_multiplier = 1.0  # Forward or diagonal forward
	elif Input.is_action_pressed("backwards_walk"):
		speed_multiplier = BACKWARD_MULTIPLIER  # Backward or diagonal backward
	elif Input.is_action_pressed("left_walk") or Input.is_action_pressed("right_walk"):
		speed_multiplier = STRAFE_MULTIPLIER  # Pure strafe
	
	# Convert to world space direction
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# --- Gravity ---
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif velocity.y < 0:
		velocity.y = 0

	# --- Jump ---
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- Sprint ---
	var base_speed = SPEED
	if stamina_component:
		base_speed *= stamina_component.update(delta, Input.is_action_pressed("sprint"), direction.length() > 0)
	
	# Apply speed multiplier
	var final_speed = base_speed * speed_multiplier

	# --- Apply Movement ---
	if direction.length() > 0:
		velocity.x = direction.x * final_speed
		velocity.z = direction.z * final_speed
	else:
		var decel = SPEED * 10 * delta
		velocity.x = move_toward(velocity.x, 0, decel)
		velocity.z = move_toward(velocity.z, 0, decel)

	move_and_slide()

	# --- Camera Bobbing ---
	if camera and camera.has_method("apply_bob"):
		camera.apply_bob(direction, delta)
