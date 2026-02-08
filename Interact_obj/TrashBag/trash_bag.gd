extends Node3D

@onready var bagBody = $"."
@onready var throw_force := 12.0
@onready var upward_boost := 7


func pick_up(player):
	player.trashBag = bagBody
	bagBody.reparent(player.hand)
	# Disable physics while held
	bagBody.freeze = true
	bagBody.transform = Transform3D.IDENTITY
	bagBody.set_collision_layer(0)
	bagBody.set_collision_mask(0)
	bagBody.sleeping = true
	# Stop all motion
	bagBody.linear_velocity = Vector3.ZERO
	bagBody.angular_velocity = Vector3.ZERO

	# Go to hand
	global_position = player.hand.global_position
	
func throw_trash(throw_origin):
	
	#Reparent to level
	bagBody.reparent(get_tree().current_scene)
	
	# Move bag to throw point
	bagBody.global_position = throw_origin.global_position
	
	# Switch back to physics
	bagBody.set_collision_layer(2)
	# Collide with layer 1 and 3
	bagBody.collision_mask = (1 << 0) | (1 << 2)

	bagBody.freeze = false
	bagBody.sleeping = false
	
	# Calculate throw direction
	var forward = -throw_origin.global_transform.basis.z.normalized()

	# Apply impulse
	bagBody.apply_impulse(forward * throw_force + Vector3(0,upward_boost,0))
