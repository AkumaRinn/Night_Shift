extends Node

@export var max_stamina := 100.0
@export var drain_rate := 7.0
@export var recover_rate := 10.0
@export var sprint_multiplier := 1.8

var stamina := max_stamina
var can_sprint := true
@onready var progressbar = $"../PlayerCanvas/ProgressBar"

func _ready():
	progressbar.value = max_stamina
	progressbar.step = drain_rate
	progressbar.visible = false
	

func update(delta: float, wants_sprint: bool, is_moving: bool) -> float:
	var multiplier := 1.0

	if wants_sprint and is_moving and can_sprint:
		multiplier = sprint_multiplier
		stamina -= drain_rate * delta
		progressbar.step = drain_rate
		progressbar.value = stamina
		progressbar.visible = true
		if stamina <= 0:
			stamina = 0
			can_sprint = false
	else:
		if stamina < max_stamina:
			stamina += recover_rate * delta
			progressbar.step = recover_rate
			progressbar.value = stamina
			if stamina >= max_stamina:
				stamina = max_stamina
				can_sprint = true
				progressbar.visible = false

	return multiplier
