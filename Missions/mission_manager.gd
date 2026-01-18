class_name MissionManager extends Node

@onready var canvas_layer: CanvasLayer = MissionControl.get_node("Mission_Canvas")
@onready var mission_label: RichTextLabel = canvas_layer.get_node("mission_label")


enum MissionStatus
{
	available,
	started,
	reached_goal,
	finished,
}

var mission_status: MissionStatus = MissionStatus.available
