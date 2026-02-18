extends Node3D

@onready var canisterBody = $"."
@onready var release_item_force = 2

func equip_canister(player):
	player.gasCanister = canisterBody
	canisterBody.reparent(player.hand)
	# Disable physics while held
	canisterBody.freeze = true
	canisterBody.transform = Transform3D.IDENTITY
	canisterBody.set_collision_layer(0)
	canisterBody.set_collision_mask(0)
	canisterBody.sleeping = true
	# Stop all motion
	canisterBody.linear_velocity = Vector3.ZERO
	canisterBody.angular_velocity = Vector3.ZERO

	# Go to hand
	global_position = player.hand.global_position
	
func release_canister(throw_origin):
	
	#Reparent to level
	canisterBody.reparent(get_tree().current_scene)

	# Switch back to physics
	canisterBody.set_collision_layer(2)
	# Collide with layer 1 and 3
	canisterBody.collision_mask = (1 << 0) | (1 << 2)

	canisterBody.freeze = false
	canisterBody.sleeping = false
	
	# Calculate throw direction
	var forward = -throw_origin.global_transform.basis.z.normalized()

	# Apply impulse
	canisterBody.apply_impulse(forward * release_item_force)
