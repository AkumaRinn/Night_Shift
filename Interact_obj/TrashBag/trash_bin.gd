extends Area3D

@export var player: CharacterBody3D

func _on_body_entered(body):
	if body.is_in_group("player"):
		var player_node = body.get_node("PlayerController")
		#[Handle trash drop]
		if player_node.trashBag && player_node.player_mission.trash_mission_flag:
			player_node.trashBag.throw_trash(body.camera)
			player_node.trashBag = null
			#[Mission Progression]
			player_node.player_mission.mission_finished()
	if body.is_in_group("trash_bag"): # if the player just throws the trash bag
		#[Mission Progression]
		var player_node = player.get_node("PlayerController")
		if player_node.player_mission.trash_mission_flag:
			player_node.player_mission.mission_finished()
			
	
