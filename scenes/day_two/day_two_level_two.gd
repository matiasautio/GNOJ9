extends Level


var next_phrases = 0
var cop_triggered = false


func _on_DialogueBox_next_phrase_requested():
	next_phrases += 1
	if next_phrases == 1:
		$"../Control/Boss".toggle_status()#visible = false
		$"../Control/Cop".visible = true

func prompt_end():
	$"../grid".can_play = false
	ask_for_grid_pause()
	
	# special case if player is ending the game by getting fired or killing the boss
	if boss.current_dialogue == "hit_boss_dead" or boss.current_dialogue == "hit_boss_fired":
		return
	
	#boss.toggle_status()
	
	print("level state is ", level_state)
	if level_state == 2:
		#$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(end_of_level_dialogue)
		boss.toggle_status()
		#level_state = 3
		if times_played == 0:
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(end_of_level_dialogue)
			boss.can_talk_to = true
			times_played += 1
		else:
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(wanna_quit_dialogue)
			current_dialogue = "wanna_quit"
		#current_dialogue = "wanna_quit"
		
	# level goal is reached
	elif level_state == 3:
		print("level state is 3 so imma go there")
		if times_played == 0:
			print("is boss present ", boss.is_present)
			#boss.is_present = false
			boss.play("default")
			boss.toggle_status()
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(end_of_level_dialogue)
			boss.can_talk_to = true
			times_played += 1
		else:
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(wanna_quit_dialogue)
			current_dialogue = "wanna_quit"
	
	elif level_state == 4:
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(wanna_quit_dialogue)
		current_dialogue = "wanna_quit"
		level_state = 3
		print("player has clicked on the boss, level state is now ", level_state)
		
	# reset
	elif level_state == 5:
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(protester_treshold_met_dialogue)
		current_dialogue = "restart"
		# boss.can_talk_to = false
		return
	
	# go to cop scene
	elif level_state == 6:
		if !cop_triggered:
			$"../Control/timer_text".pause_countdown()
			cop_triggered = true
			$"../Control/Cop".visible = true
			$"../Control/Cop".animation = "default"
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(cop_treshold_met_dialogue)
			current_dialogue = "restart"
			# boss.can_talk_to = false
			return
