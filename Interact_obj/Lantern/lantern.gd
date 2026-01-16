extends RigidBody3D

@onready var interact_label = $"../interact_label"

func _ready():
	pass # Replace with function body.


func _process(_delta):
		pass
		
func interact():
	interact_label.visible = false
