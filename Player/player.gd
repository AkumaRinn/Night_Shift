extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 6.7
const SPRINT_VELOCITY = 2
const STRAFE_MULTIPLIER = 0.6 

var picked = 0
var inventory: Array[Node3D] = []
var inv_index: int = -1
var equipped_item: Node3D = null



@onready var camera = $Camera3D
@onready var reach = $Camera3D/RayCast3D
@onready var hand = $Camera3D/hand
@onready var light = $Camera3D/light

func add_to_inventory(item: Node3D):
	item.freeze = true
	item.reparent(hand)
	item.transform = Transform3D.IDENTITY
	item.visible = false

	inventory.append(item)

	# Auto-equip first item
	if inv_index == -1:
		equip_item(0)

func equip_item(index: int):
	# Unequip (empty hands)
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


func _ready():
	light.visible = not light.visible
	# Make mouse dissapear
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event.is_action_pressed("inventory_next"):
		if inv_index == -1:
			equip_item(0)
		else:
			equip_item(-1)

	elif event.is_action_pressed("inventory_prev"):
		if inv_index == -1:
			equip_item(0)
		else:
			equip_item(-1)
	
	
	# Camera movement start
	if event is InputEventMouseMotion:
		var sens = Settings.mouse_sensitivity
		rotation_degrees.y -= event.relative.x * sens
		camera.rotation_degrees.x -= event.relative.y * sens
		camera.rotation_degrees.x = clamp(
			camera.rotation_degrees.x, -80, 80
		)
	# Camera movement stop
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):

	if reach.is_colliding():
		var object = reach.get_collider()
		if object.is_in_group("lantern"):
			if Input.is_action_just_pressed("interact"):
				add_to_inventory(object)

	
	if Input.is_action_just_pressed("flashlight"):
		if equipped_item and equipped_item.is_in_group("lantern"):
			light.visible = not light.visible

	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	velocity.y -= 20 * delta # Gravitational pull
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("left_walk", "right_walk", "forward_walk", "backwards_walk")
	# Slow down strafing
	input_dir.x *= STRAFE_MULTIPLIER
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		# Sprinting start
		if Input.is_action_pressed("sprint"):
			velocity.z *= SPRINT_VELOCITY 
			velocity.x *= SPRINT_VELOCITY
		# Sprinting stop
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
