extends Node


# states are: 0 = beginning, 1 = intro done, 2 = gameplay, 3 = goal reached, 4 = replay
var level_state = 0

var current_dialogue = null

const current_level = 2

var boss_just_hurt = false

# grid pause hack
var times_paused = 0

# scoring
var highest_score = 0


func _ready():
	get_node("/root/game_data").current_level = current_level
	$"../Control/Boss".current_level = self


func _on_DialogueBox_dialog_box_closed():
	level_state += 1
	if level_state == 1:
		$"../Control/input_blocker".visible = false
		#$"../grid".can_play = true
		#$"../Control/Boss".toggle_status()
		$"../Control/timer_text".level = self
		$"../Control/timer_text".start_countdown()
	if level_state == 2:
		if current_dialogue == "level_two_restart":
			# if boss is already interactable we don't to want to hide him
			#if $"../Control/Boss".can_talk_to == false:
				#$"../Control/Boss".toggle_status()
			reset_level()
			#get_tree().change_scene("res://scenes/game_window_two.tscn")
		else:
			$"../Control/continue_game".visible = true
		#get_tree().change_scene("res://scenes/game_window_three.tscn")
	if level_state >= 3:
		if current_dialogue == "level_two_restart":
			# if boss is already interactable we don't to want to hide him
			#if $"../Control/Boss".can_talk_to == false:
				#$"../Control/Boss".toggle_status()
			reset_level()
		if current_dialogue == "level_two_continue":
			game_data.current_score += highest_score
			get_tree().change_scene("res://scenes/game_window_rocks.tscn")
		if current_dialogue == "level_two_wanna_quit":
			$"../Control/continue_game".visible = true
		if current_dialogue == "level_two_stay":
			reset_level()
		#$"../Control/continue_game".visible = true
	#if current_dialogue == "level_one_continue":
		#next_level()
	$"../Control/Boss".toggle_status()
	current_dialogue = null


func prompt_end():
	var score = $"../score_keeper".score
	var boss = $"../Control/Boss"
	var times_played =$"../Control/timer_text".times_played
	
	ask_for_grid_pause()
	$"../Control/timer_text".pause_countdown()
	
	# special case if player is ending the game by getting fired or killing the boss
	if boss.current_dialogue == "hit_boss_dead" or boss.current_dialogue == "hit_boss_fired":
		return
	
	$"../grid".can_play = false
	boss.toggle_status()
	if times_played == 1:
		if score > 0:
			boss.can_talk_to = true
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_two_001.json")
		else:
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_two_restart.json")
			current_dialogue = "level_two_restart"
	else:
#		if score > 0:
		boss.can_talk_to = true
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_two_wanna_quit.json")
		current_dialogue = "level_two_wanna_quit"
		# if the player has passed once, we'll just let them leave
#		else:
#			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_two_restart.json")
#			current_dialogue = "level_two_restart"
	if $"../score_keeper".score > highest_score:
		highest_score = $"../score_keeper".score


func reset_level():
	$"../Control/timer_text".start_countdown()
	$"../score_keeper".reset_score()
	$"../grid".reset()
	$"../grid".can_play = $"../Control/tool_saw".is_selected


func _on_stay_button_down():
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_two_stay.json")
	current_dialogue = "level_two_stay"
	$"../Control/continue_game".visible = false


func _on_continue_button_down():
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_two_continue.json")
	$"../Control/continue_game".visible = false
	current_dialogue = "level_two_continue"
	#prompt_end()


func ask_for_grid_pause():
	if times_paused < 3:
		times_paused += 1
		$"../grid".pause()
		$"../grid_pauser".start()
	elif times_paused == 3:
		times_paused = 0


func _on_grid_pauser_timeout():
	ask_for_grid_pause()
