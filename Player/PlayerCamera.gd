extends Camera3D

# --- Camera rotation ---
@export var invert_y: bool = false
@export var vertical_scale: float = 0.5
@export var sensitivity_scaling: float = 0.01
@export var camera_height: float = 0.8

# --- Crouch ---
@export var crouch_height_offset: float = -0.6   # camera goes lower
@export var crouch_lerp_speed: float = 10.0

# --- Camera bobbing ---
var bob_timer := 0.0
var bob_speed := 10.0
var bob_amount := 0.1

# --- Internal state ---
var current_height := 0.0
var bob_offset := 0.0
var vertical_rotation := 0.0
var target_crouch_height := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_height = camera_height
	target_crouch_height = camera_height
	transform.origin = Vector3(0, camera_height, 0)
	vertical_rotation = rotation.x

func _process(delta):
	_update_crouch(delta)
	_apply_camera_position()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var sens = _get_sensitivity() * sensitivity_scaling
		if get_parent():
			get_parent().rotate_y(-event.relative.x * sens)
		var delta_y = event.relative.y * sens * vertical_scale
		var should_invert = invert_y
		if has_node("/root/Settings"):
			should_invert = get_node("/root/Settings").invert_y
		if should_invert:
			delta_y *= -1
		vertical_rotation -= delta_y
		vertical_rotation = clamp(vertical_rotation, deg_to_rad(-80), deg_to_rad(80))
		rotation.x = vertical_rotation
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# --- Crouch setter ---
func set_crouch(state: bool) -> void:
	if state:
		target_crouch_height = camera_height + crouch_height_offset
	else:
		target_crouch_height = camera_height

func _update_crouch(delta: float):
	current_height = lerp(current_height, target_crouch_height, crouch_lerp_speed * delta)

# --- Camera bobbing ---
func apply_bob(movement_dir: Vector3, delta: float):
	if movement_dir.length() > 0:
		bob_timer += bob_speed * delta
		bob_offset = sin(bob_timer) * bob_amount
	else:
		bob_timer = 0.0
		bob_offset = lerp(bob_offset, 0.0, 10.0 * delta)

# --- Final camera position ---
func _apply_camera_position():
	transform.origin = Vector3(0, current_height + bob_offset, 0)

# --- Settings ---
func _get_sensitivity() -> float:
	if has_node("/root/Settings"):
		return get_node("/root/Settings").mouse_sensitivity
	return 1.0
