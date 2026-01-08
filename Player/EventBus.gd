# EventBus.gd (autoload)
extends Node

signal sensitivity_changed(new_sensitivity: float)
signal invert_y_changed(is_inverted: bool)

var mouse_sensitivity: float = 0.15:
	set(value):
		mouse_sensitivity = value
		sensitivity_changed.emit(value)

var invert_y_axis: bool = false:
	set(value):
		invert_y_axis = value
		invert_y_changed.emit(value)
