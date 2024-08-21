extends Level


func _on_grid_match_made(_number_of_tiles, _tile_group):
	if game_data.get_node("player_status").current_tool == 2 and !has_boss_reacted:
		has_boss_reacted = true
		#$"../Control/Boss".toggle_status()
		yield(get_tree().create_timer(1.5), "timeout")
		$"../Control/Boss".animation = "default"
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/day_two/day_two_one_tape_reaction.json")
		current_dialogue = "day_two_one_tape_reaction"


func _on_DialogueBox_dialog_box_closed():
	if level_state == 0:
		#level_state = 2
		$"../Control/Boss".animation = "away"
		$"../Control/input_blocker".visible = false
	
	# Include these in every level
	elif level_state == 3:
		$"../Control/continue_game".visible = true
	elif level_state == 4:
		reset_level()
	elif level_state == 7:
		level_state = 4
	elif level_state == 10:
		next_level()
