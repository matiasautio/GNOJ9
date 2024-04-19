extends Level

# cop tries to catch the player
# after one succesful round of stopping the cops
# the cop stays on screen as is killable


var cop_piece = preload("res://scenes/pieces/police_piece.tscn")
var next_phrases = 0
var is_raid_over = false

# res://dialogue/cop_raid_failed.json

func other_init():
	cop_treshold = 999


func _on_DialogueBox_dialog_box_closed():
	if level_state == 0:
		level_state = gameplay_state
		if $"../Control/Boss".visible:
			$"../Control/Boss".animation = "away"
		if $"../Control/Cop".visible:
			#$"../Control/Cop".animation = "away"
			$"../Control/Cop".toggle_status()
		if $"../Control/Protester".visible:
			$"../Control/Protester".animation = "away"
		$"../Control/input_blocker".visible = false
	elif level_state == 2:
		$"../grid".possible_pieces.erase(cop_piece)
		moves += 5
		reset_level()
		$"../grid".possible_pieces.append(cop_piece)
		#spawn_first_cop()
	elif level_state == 3:
		prompt_end()
	elif level_state == 4:
		var _x = get_tree().change_scene(main_menu)
	elif level_state == 6:
		var _x = get_tree().change_scene(cop_scene)


func _on_DialogueBox_next_phrase_requested():
	next_phrases += 1
	if next_phrases == 2:
		$"../Control/Cop".animation = "happy"
		$"../grid".possible_pieces.append(cop_piece)


func spawn_first_cop():
	var first_cop_pos = Vector2(int(rand_range(0,7)),$"../grid".height - 1)
	var first_cop_piece = cop_piece.instance()
	$"../grid".add_child(first_cop_piece)
	$"../grid".all_pieces[first_cop_pos.x][first_cop_pos.y].queue_free()
	first_cop_piece.position = $"../grid".grid_to_pixel(first_cop_pos.x, first_cop_pos.y)
	$"../grid".all_pieces[first_cop_pos.x][first_cop_pos.y] = first_cop_piece


func check_tiles_after_match():
	for x in $"../grid".width:
		if $"../grid".all_pieces[x][0] != null and $"../grid".all_pieces[x][0].color == "cop":
			level_state = 4
			prompt_end()

func _on_move_keeper_moves_deplenished():
	print("moves deplenished")
	#level_state = 2
	prompt_end()


func prompt_end():
	$"../grid".can_play = false
	ask_for_grid_pause()
	
	if level_state == 2:
		times_played += 1
		if times_played == 3:
			is_raid_over = true
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(end_of_level_dialogue)
			level_state = 3
			return
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(wanna_quit_dialogue)
		current_dialogue = "wanna_quit"
		$"../Control/Cop".toggle_status()
		$"../Control/Cop".can_talk_to = true
		
		#$"../Control/Cop".animation = "happy"
	elif level_state == 3:
		if is_raid_over:
			var _x = get_tree().change_scene("res://scenes/day_two/day_two_level_three.tscn")#game_data.previous_level_name)
		else:
			var _x = get_tree().change_scene("res://scenes/day_two/day_two_cop_died.tscn")
	elif level_state == 4:
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/cop_raid_failed.json")
		$"../Control/Cop".toggle_status()
		$"../Control/Cop".can_talk_to = true


func _on_grid_pieces_generated():
	spawn_first_cop()


func _on_Cop_dead():
	level_state = 3
	#var _x = get_tree().change_scene(game_data.previous_level_name)
