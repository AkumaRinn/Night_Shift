extends RigidBody3D

@onready var is_equiped = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func interact(player):
	self.visible = true
	self.freeze = true
	self.reparent(player.hand)
	self.transform = Transform3D.IDENTITY
	self.set_collision_layer(0)
	self.set_collision_mask(0)
	self.is_equiped = true

func drop_pump(_player):
	self.visible = false
	self.freeze = false
	self.reparent($".")
	self.transform = Transform3D.IDENTITY
	self.set_collision_layer(2)
	self.set_collision_mask(1)
	self.is_equiped = false
	
func pump_gas():
	pass
	
func _process(_delta):
	pump_gas()
