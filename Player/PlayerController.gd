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
@onready var item_drop = canvas.get_node("drop_label")
@onready var item_use = canvas.get_node("use_label")

@onready var player_mission_manager =$"../MissionManagerScene"
@onready var player_mission
@onready var hintLabel = $"../PlayerCanvas/HintLabel"
@onready var hintTimer = $"../HintTimer"

#Some abomination to be able to assign the player camera to the portals
@onready var levelNode = get_parent().get_parent()
@onready var portal1 = levelNode.get_node("Location1")
@onready var portal2 = levelNode.get_node("Location2")

#Phone logs access point for save_load
@onready var logsList = $"../PlayerCanvas/PhoneUI/LogsPage/ScrollContainer/LogsList"


# --- Inventory ---
var inventory: Array[Node3D] = []
var inv_index: int = -1
var equipped_item: Node3D = null
var object = null #For pump check
var obj = null
var equipped_pump: Node3D = null
var trashBag: RigidBody3D = null
var gasCanister = null


# --- Pickup settings ---
@export var interact_distance := 3.0

func _ready():
	# Assign the camera to the portals
	portal1.player_camera = camera
	portal2.player_camera = camera
	var player_node = get_parent()
	var player_controller = self
	SaveLoadAutoload.register_player(player_node, player_controller, logsList)
	await player_mission_manager.ready
	player_mission = player_mission_manager.current_mission
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
	
	drop_item()
	
	# Handle Interaction
	if obj and obj.is_in_group("lantern"):
		var distance = camera.global_position.distance_to(obj.global_position)
		var lantern_body = obj.get_parent()
		if distance <= interact_distance:
			interact_hint.text = "Flashlight [E]"
			interact_hint.visible = true
			if Input.is_action_just_pressed("interact"):
				add_to_inventory(lantern_body)
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
	elif obj and obj.is_in_group("trash_bag"):
		var distance = camera.global_position.distance_to(obj.global_position)
		if distance <= interact_distance:
			interact_hint.text = "Trash Bag [E]"
			interact_hint.visible = true
			if Input.is_action_just_pressed("interact"):
				item_drop.visible = true
				item_use.text = "Eat [Click]"
				item_use.visible = true
				obj.pick_up(self)
	elif obj and obj.is_in_group("generator"):
		var distance = camera.global_position.distance_to(obj.global_position)
		if distance <= interact_distance:
			interact_hint.text = "Generator [E]"
			interact_hint.visible = true
			if Input.is_action_just_pressed("interact") and gasCanister:
				if gasCanister.is_filled:
					obj.fill_generator()
			if Input.is_action_just_pressed("interact")  and not gasCanister:
				hintLabel.visible = true
				hintLabel.text = "You need a diesel canister"
				hintTimer.start()
	elif obj and obj.is_in_group("canister"):
		var distance = camera.global_position.distance_to(obj.global_position)
		if distance <= interact_distance:
			interact_hint.text = "Canister [E]"
			interact_hint.visible = true
			if Input.is_action_just_pressed("interact"):
				obj.equip_canister()
			if equipped_pump and Input.is_action_just_pressed("use_item"):
				obj.fill_canister()
	
	
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
		if trashBag:
			item_use.text = "Damn, you are nasty"
			
	# Stop the pump
	if Input.is_action_just_released("use_item"):
		fill_progress.visible = false
		gas_particles.emitting = false
		
# END OF _process FUNCTION


# --- Inventory / flashlight functions ---
func add_to_inventory(item: Node3D): 
	#Object needs to have a var for its collision body named 'object_body'
	if not hand or not item:
		return
	var item_body = item.object_body
	item_body.freeze = true
	item_body.set_collision_layer(0)
	item_body.set_collision_mask(0)
	item.is_picked_up = true
	item.reparent(hand)
	item.transform = Transform3D.IDENTITY
	item.visible = false

	inventory.append(item)
	if inv_index == -1:
		equip_item(0)


func drop_item():
	if Input.is_action_just_pressed("drop_item") and equipped_pump: # pump drop
		item_dropped()
		equipped_pump.drop_pump(self)
	if Input.is_action_just_pressed("drop_item") and trashBag: # trash throw
		trashBag.throw_trash(camera)
		item_use.text = "Use [Click]"
		item_dropped()
		trashBag = null

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
		AudioManager.lantern_sound.play()
		light.visible = not light.visible


func _on_hint_timer_timeout():
	# Reset hint text and visibility
	hintLabel.visible = false
	hintLabel.text = ""
