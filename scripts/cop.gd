extends Character


func _on_cop_button_button_down():
	clicked()


func clicked():
	if can_talk_to:
		var current_tool = player_status.current_tool
		print(current_tool)
		# player has nothing equipped
		if current_tool == 0:#$"../../player_status".none:
			# $"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_one_continue.json")
			# current_dialogue = "level_one_continue"
			if current_level == 1:
				$"../../level_one".prompt_end()
			elif current_level == 2:
				$"../../level_two".prompt_end()
			elif current_level == 3:
				$"../../level_three".prompt_end()
		# player has the saw equipped
		elif current_tool == 1:#$"../../player_status".saw:
			#boss_health -= 1
			#boss_annoyance += 1
			#if boss_health == 0:
			animation = "hurt"
			$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/hit_boss_dead.json")
			can_talk_to = false
			current_dialogue = "hit_boss_dead"
			emit_signal("dead")
		elif current_tool == 2:
			$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/cop_muffled.json")
			#can_talk_to = false
			#current_dialogue = "hit_boss_dead"
#			else:
#				if boss_annoyance < annoyance_treshold:
#					$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/hit_boss.json")
#					if boss_annoyance == annoyance_treshold - 1:
#						$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/hit_boss_last_warning.json")
#					can_talk_to = false
#					current_dialogue = "hit_boss"
#				else:
#					$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/hit_boss_fired.json")
#					can_talk_to = false
#					current_dialogue = "hit_boss_fired"
		#elif current_level == 2:
			#$"../../level_two".prompt_end()
		#elif current_level == 3:
			#$"../../level_three".prompt_end()
		#game_data.boss_health = boss_health
