extends CharacterBody3D

# --- Movement Constants ---
const SPEED = 4.5
const JUMP_VELOCITY = 6.7
const SPRINT_MULTIPLIER = 1.8
const STRAFE_MULTIPLIER = 0.6
const GRAVITY = 44.1  # Approximate Godot 3D gravity

# --- Stamina ---
const MAX_STAMINA = 5.0
const STAMINA_DRAIN = 1.5
const STAMINA_RECOVER = 1.0
var stamina = MAX_STAMINA
var can_sprint = true

# --- Inventory ---
var inventory: Array[Node3D] = []
var inv_index: int = -1
var equipped_item: Node3D = null

# --- Node References ---
@onready var camera = $Camera3D
@onready var reach = $Camera3D/RayCast3D
@onready var hand = $Camera3D/hand
@onready var light = $Camera3D/light

# --- Camera Bobbing ---
var bob_timer = 0.0
var bob_speed = 10.0       # Speed of bobbing
var bob_amount = 0.10     # Bob height
var original_camera_position = Vector3.ZERO

# --- Inventory Functions ---
func add_to_inventory(item: Node3D):
	item.freeze = true
	item.reparent(hand)
	item.transform = Transform3D.IDENTITY
	item.visible = false
	inventory.append(item)

	if inv_index == -1:
		equip_item(0)

func equip_item(index: int):
	if index == -1:
		if inv_index != -1:
			inventory[inv_index].visible = false
		inv_index = -1
		equipped_item = null
		light.visible = false
		return

	if inventory.is_empty():
		return

	index = (index + inventory.size()) % inventory.size()

	if inv_index != -1:
		inventory[inv_index].visible = false

	inv_index = index
	inventory[inv_index].visible = true
	equipped_item = inventory[inv_index]

# --- Ready ---
func _ready():
	light.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	original_camera_position = camera.transform.origin

# --- Input Handling ---
func _unhandled_input(event):
	# Inventory cycling
	if event.is_action_pressed("inventory_next") and inventory.size() > 0:
		if inv_index == -1:
			equip_item(0)
		else:
			equip_item((inv_index + 1) % inventory.size())
	elif event.is_action_pressed("inventory_prev") and inventory.size() > 0:
		if inv_index == -1:
			equip_item(0)
		else:
			equip_item((inv_index - 1 + inventory.size()) % inventory.size())

	# Camera rotation
	if event is InputEventMouseMotion:
		var sens = Settings.mouse_sensitivity
		rotation_degrees.y -= event.relative.x * sens
		camera.rotation_degrees.x -= event.relative.y * sens
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -80, 80)

	# Unlock mouse
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# --- Camera Bobbing Function ---
func apply_camera_bob(direction: Vector3, delta: float):
	if direction.length() > 0:
		bob_timer += bob_speed * delta
		var bob_offset = sin(bob_timer) * bob_amount
		camera.transform.origin = original_camera_position + Vector3(0, bob_offset, 0)
	else:
		# Reset when idle
		bob_timer = 0
		camera.transform.origin = original_camera_position

# --- Physics / Movement ---
func _physics_process(delta):
	# --- Pickup interaction ---
	if reach.is_colliding():
		var object = reach.get_collider()
		if object.is_in_group("lantern") and Input.is_action_just_pressed("interact"):
			add_to_inventory(object)

	# --- Flashlight toggle ---
	if Input.is_action_just_pressed("flashlight"):
		if equipped_item and equipped_item.is_in_group("lantern"):
			light.visible = not light.visible

	# --- Movement input ---
	var input_dir = Input.get_vector("left_walk", "right_walk", "forward_walk", "backwards_walk")
	input_dir.x *= STRAFE_MULTIPLIER
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# --- Gravity & Jump ---
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		if velocity.y < 0:
			velocity.y = 0

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- Sprint & stamina ---
	var speed = SPEED
	if direction and Input.is_action_pressed("sprint") and can_sprint:
		speed *= SPRINT_MULTIPLIER
		stamina -= STAMINA_DRAIN * delta
		if stamina <= 0:
			stamina = 0
			can_sprint = false
	else:
		if stamina < MAX_STAMINA:
			stamina += STAMINA_RECOVER * delta
			if stamina >= MAX_STAMINA:
				stamina = MAX_STAMINA
				can_sprint = true

	# --- Apply movement ---
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		# Smooth deceleration when no input
		var decel = SPEED * 10 * delta
		velocity.x = move_toward(velocity.x, 0, decel)
		velocity.z = move_toward(velocity.z, 0, decel)

	move_and_slide()

	# --- Apply camera bobbing ---
	apply_camera_bob(direction, delta)
