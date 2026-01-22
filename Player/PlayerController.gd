# PlayerController.gd
extends Node

# --- Node references ---
@onready var rand_gen = RandomNumberGenerator.new()
@onready var camera = get_parent().get_node_or_null("Camera3D") 
@onready var reach = camera.get_node_or_null("RayCast3D")
@onready var hand = camera.get_node_or_null("hand")
@onready var light = camera.get_node_or_null("light")
@onready var gas_particles = hand.get_node_or_null("gas_particles")
@onready var canvas = get_parent().get_node_or_null("PlayerCanvas")
@onready var fill_progress = $"../PlayerCanvas/fill_progress_bar"
@onready var grain_eff = $"../PlayerCanvas/grain_effect"
@onready var interact_hint = $"../PlayerCanvas/interactable_label"
@onready var item_drop = canvas.get_node("drop_label")#$"../PlayerCanvas/drop_label"
@onready var item_use = canvas.get_node("use_label")#$"../$PlayerCanvas/use_label"

@onready var player_mission_manager =$"../MissionManagerScene"
@onready var player_mission

# --- Inventory ---
var inventory: Array[Node3D] = []
var inv_index: int = -1
var equipped_item: Node3D = null
var object = null #For pump check
var obj = null
var equipped_pump: Node3D = null

# --- Pickup settings ---
@export var interact_distance := 3.0

func _ready():
	await player_mission_manager.ready
	player_mission = player_mission_manager.current_mission
	print(player_mission)
	if light:
		light.visible = false
	
func item_dropped():
	item_drop.visible = false
	item_use.visible = false
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
	player_mission = player_mission_manager.current_mission
	#Apply grain effect
	grain_eff.texture.noise.seed = rand_gen.randi()
	
	if not reach or not reach.is_enabled():
		return

	reach.force_raycast_update()
	if reach.is_colliding():
		obj = reach.get_collider()
	else:
		obj = null
		interact_hint.text = ""
		interact_hint.visible = false
	
	drop_gas_pump()
	
	# Handle Interaction
	if obj and obj.is_in_group("lantern"):
		var distance = camera.global_position.distance_to(obj.global_position)
		if distance <= interact_distance:
			interact_hint.text = "Flashlight [E]"
			interact_hint.visible = true
			if Input.is_action_just_pressed("interact"):
				add_to_inventory(obj)
	elif obj and obj.is_in_group("door"):
		var distance = camera.global_position.distance_to(obj.global_position)
		if distance <= interact_distance:
			interact_hint.text = "Door [E]"
			interact_hint.visible = true
			if Input.is_action_just_pressed("interact"):
				obj.interact(self)
	elif obj and obj.is_in_group("gas_pump"):
		var distance = camera.global_position.distance_to(obj.global_position)
		if distance <= interact_distance:
			interact_hint.text = "Gas Pump [E]"
			interact_hint.visible = true
			if Input.is_action_just_pressed("interact"):
				item_drop.visible = true
				item_use.visible = true
				obj.interact(self)
	elif obj and obj.get_parent().is_in_group("punch_machine"):
		var punch_machine = obj.get_parent()
		var distance = camera.global_position.distance_to(obj.global_position)
		if distance <= interact_distance:
			interact_hint.text = "Punch In/Out [E]"
			interact_hint.visible = true
			if Input.is_action_just_pressed("interact"):
				punch_machine.interact(self)
	
	
	# Use the pump
	if Input.is_action_pressed("use_item"):
		if equipped_pump:
			gas_particles.emitting = true
			gas_particles.rotation = camera.rotation
			if obj and obj.is_in_group("car"):
				var car_node = obj.get_parent()
				if not car_node.is_activated:
					fill_progress.visible = true
					fill_progress.value += fill_progress.step
					car_node.interact(self)
	
			
	# Stop the pump
	if Input.is_action_just_released("use_item"):
		fill_progress.visible = false
		gas_particles.emitting = false
		

# END OF _process FUBCTION

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


func drop_gas_pump():
	if Input.is_action_just_pressed("drop_item") and equipped_pump:
		item_dropped()
		equipped_pump.drop_pump(self)
	


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
