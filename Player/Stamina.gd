extends Node

@export var max_stamina := 5.0
@export var drain_rate := 1.5
@export var recover_rate := 1.0
@export var sprint_multiplier := 1.8

var stamina := max_stamina
var can_sprint := true

func update(delta: float, wants_sprint: bool, is_moving: bool) -> float:
	var multiplier := 1.0

	if wants_sprint and is_moving and can_sprint:
		multiplier = sprint_multiplier
		stamina -= drain_rate * delta
		if stamina <= 0:
			stamina = 0
			can_sprint = false
	else:
		if stamina < max_stamina:
			stamina += recover_rate * delta
			if stamina >= max_stamina:
				stamina = max_stamina
				can_sprint = true

	return multiplier
