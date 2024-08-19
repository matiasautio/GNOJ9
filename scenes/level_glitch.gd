extends Level


# stupid hack to force the boss to stay on screen if the glitch is
# removed while replaying
# Could be solved by adding a check to the boos if the should always be on screen
# ie. the player is replaying a level
var replaying = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_DialogueBox_dialog_box_closed():
	if level_state == 0:
		level_state = 2
		if boss.visible and !replaying:
			boss.animation = "away"
		if $"../Control/Cop" != null and $"../Control/Cop".visible:
			$"../Control/Cop".animation = "away"
			$"../Control/Cop".visible = false
		if $"../Control/Protester" != null and $"../Control/Protester".visible:
			$"../Control/Protester".animation = "away"
			$"../Control/Protester".visible = false
		$"../Control/input_blocker".visible = false
	elif level_state == 2:
		#level_state = 3
		$"../Control/continue_game".visible = true
	elif level_state == 3:
		$"../Control/continue_game".visible = true
	# Level reset was selected
	elif level_state == 4:
		print("Level state is ", level_state, " and the boss hurt is ", boss_just_hurt)
		if boss_just_hurt:
			boss_just_hurt = false
			return
		replaying = true
		reset_level()
	# Too many protesters were cut down, level resets
	elif level_state == 5:
		reset_level()
	elif level_state == 6:
		#game_data.previous_level_name = current_level_name
		var _x = get_tree().change_scene(cop_scene)
	elif level_state == 10:
		next_level()


func _on_Glitch_glitch_removed():
	level_state = 0
	boss.toggle_status()
	boss.toggle_status()
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_glitch_removed.json")
	$"../score_keeper".can_score = true
	$"../grid/Destroy".play_audio()


func _on_score_keeper_cannot_score():
	if !has_boss_reacted:
		has_boss_reacted = true
		yield(get_tree().create_timer(2.5), "timeout")
		# wth the is wrong with this when i need to call it twice?
		level_state = 0
		boss.toggle_status()
		boss.toggle_status()
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_glitch_001.json")


func prompt_end():
	$"../grid".can_play = false
	ask_for_grid_pause()
	
	# special case if player is ending the game by getting fired or killing the boss
	if boss.current_dialogue == "hit_boss_dead" or boss.current_dialogue == "hit_boss_fired":
		return
	
	boss.toggle_status()
	
	print("level state is ", level_state)
	if level_state == 2:
		boss.toggle_status()
		#level_state = 3
		if times_played == 0:
			if $"../score_keeper".score == 0:
				$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_glitch_end_no_points.json")
			else:
				$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(end_of_level_dialogue)
			boss.can_talk_to = true
			times_played += 1
		else:
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(wanna_quit_dialogue)
			current_dialogue = "wanna_quit"
		
	# level goal is reached
	if level_state == 3:
		print("level state is 3 so imma go there")
		if times_played == 0:
			print("is boss present ", boss.is_present)
			#boss.is_present = false
			boss.play("default")
			boss.toggle_status()
			if $"../score_keeper".score == 0:
				$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_glitch_end_no_points.json")
			else:
				$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(end_of_level_dialogue)
			boss.can_talk_to = true
			times_played += 1
		else:
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(wanna_quit_dialogue)
			current_dialogue = "wanna_quit"
	
	if level_state == 4:
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(wanna_quit_dialogue)
		current_dialogue = "wanna_quit"
		level_state = 3
		print("player has clicked on the boss, level state is now ", level_state)
		
	# reset
	if level_state == 5:
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(protester_treshold_met_dialogue)
		current_dialogue = "restart"
		# boss.can_talk_to = false
		return
	
	# go to cop scene
	if level_state == 6:
		$"../Control/Cop".visible = true
		$"../Control/Cop".animation = "default"
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(cop_treshold_met_dialogue)
		current_dialogue = "restart"
		return
