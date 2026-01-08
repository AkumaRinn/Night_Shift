# PlayerController.gd
extends Node

# --- Node references ---
@onready var camera = get_parent().get_node_or_null("Camera3D")
@onready var reach = camera.get_node_or_null("RayCast3D")
@onready var hand = camera.get_node_or_null("hand")
@onready var light = camera.get_node_or_null("light")

# --- Inventory ---
var inventory: Array[Node3D] = []
var inv_index: int = -1
var equipped_item: Node3D = null

# --- Pickup settings ---
@export var pickup_distance := 3.0

func _ready():
	if light:
		light.visible = false

# --- Input handling ---
func _unhandled_input(event):
	# Inventory cycling
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

	# Flashlight toggle
	if event.is_action_pressed("flashlight"):
		toggle_light()

# --- Pickup interaction ---
func _process(_delta):
	if not reach or not reach.is_enabled():
		return

	reach.force_raycast_update()

	if reach.is_colliding():
		var obj = reach.get_collider()
		if obj and obj.is_in_group("lantern"):
			var distance = camera.global_position.distance_to(obj.global_position)
			if distance <= pickup_distance and Input.is_action_just_pressed("interact"):
				add_to_inventory(obj)

# --- Inventory / flashlight functions ---
func add_to_inventory(item: Node3D):
	if not hand or not item:
		return
	item.freeze = true
	item.reparent(hand)
	item.transform = Transform3D.IDENTITY
	item.visible = false
	item.set_collision_layer(0)
	item.set_collision_mask(0)
	inventory.append(item)
	if inv_index == -1:
		equip_item(0)

func equip_item(index: int):
	if index == -1:
		# Unequip
		if inv_index != -1 and inv_index < inventory.size():
			inventory[inv_index].visible = false
			if inventory[inv_index].is_in_group("lantern"):
				var lantern_light = inventory[inv_index].get_node_or_null("light")
				if lantern_light:
					lantern_light.visible = false
		inv_index = -1
		equipped_item = null
		if light:
			light.visible = false
		return

	if inventory.is_empty():
		return

	index = (index + inventory.size()) % inventory.size()

	if inv_index != -1 and inv_index < inventory.size():
		inventory[inv_index].visible = false
		if inventory[inv_index].is_in_group("lantern"):
			var lantern_light = inventory[inv_index].get_node_or_null("light")
			if lantern_light:
				lantern_light.visible = false

	inv_index = index
	inventory[inv_index].visible = true
	equipped_item = inventory[inv_index]

func toggle_light():
	if equipped_item and equipped_item.is_in_group("lantern") and light:
		light.visible = not light.visible
