extends Character

signal cop_clicked


func _on_cop_button_button_down():
	clicked()


func clicked():
	if can_talk_to:
		emit_signal("cop_clicked")
		var current_tool = player_status.current_tool
		print(current_tool)
		# player has nothing equipped
		if current_tool == 0:
			$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/special/cop_clicked_reaction.json")
		# player has the saw equipped
		elif current_tool == 1:
			animation = "hurt"
			$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/cop_dead.json")
			can_talk_to = false
			current_dialogue = "hit_boss_dead"
			game_data.dead_character = "cop"
			emit_signal("dead")
		elif current_tool == 2:
			$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/special/cop_tape_reaction.json")
