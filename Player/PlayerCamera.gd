# res://Player/PlayerCamera.gd
extends Camera3D

# --- Camera rotation ---
@export var invert_y: bool = false
@export var vertical_scale: float = 0.5
@export var sensitivity_scaling: float = 0.01
@export var camera_height: float = 0.80  # Increased from default (usually 1.6)

# --- Camera bobbing ---
var bob_timer = 0.0
var bob_speed = 10.0
var bob_amount = 0.1
var original_position = Vector3.ZERO

# Current rotation values
var vertical_rotation: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Set initial height
	original_position = Vector3(0, camera_height, 0)
	transform.origin = original_position
	
	vertical_rotation = rotation.x

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Get sensitivity
		var sens = _get_sensitivity()
		
		# Apply scaling
		sens *= sensitivity_scaling
		
		# Rotate parent (player body) horizontally
		if get_parent():
			get_parent().rotate_y(-event.relative.x * sens)

		# Calculate vertical rotation
		var delta_y = event.relative.y * sens * vertical_scale
		
		# Apply invert setting
		var should_invert = _get_invert_y()
		if invert_y:
			should_invert = !should_invert
		
		if should_invert:
			delta_y *= -1
		
		# Update vertical rotation and apply it
		vertical_rotation -= delta_y
		vertical_rotation = clamp(vertical_rotation, deg_to_rad(-80), deg_to_rad(80))
		rotation.x = vertical_rotation
		
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _get_sensitivity() -> float:
	if has_node("/root/Settings"):
		var settings = get_node("/root/Settings")
		return settings.mouse_sensitivity
	return 1.0

func _get_invert_y() -> bool:
	if has_node("/root/Settings"):
		return get_node("/root/Settings").invert_y
	return false

func apply_bob(movement_dir: Vector3, delta: float):
	if movement_dir.length() > 0:
		bob_timer += bob_speed * delta
		var offset = sin(bob_timer) * bob_amount
		transform.origin = original_position + Vector3(0, offset, 0)
	else:
		bob_timer = 0.0
		transform.origin = transform.origin.lerp(original_position, 10.0 * delta)
