extends Node


# states are: 0 = beginning, 1 = intro done, 2 = gameplay, 3 = goal reached, 4 = replay, 5 = failed
var level_state = 0
var is_level_goal_reached = false
const current_level = 3

var current_dialogue

# This level limits the amount of protesters the player can cut down
var cut_protesters = 0
const protester_treshold = 10

# looping
var times_played = 0

# grid pause hack
var times_paused = 0


func _ready():
	get_node("/root/game_data").current_level = current_level
	$"../Control/Boss".current_level = current_level


func _on_DialogueBox_dialog_box_closed():
	#level_state += 1 # We are setting this differently, not by adding
	if level_state == 0:
		level_state = 1
	# after intro is done
	if level_state == 1:
		$"../Control/input_blocker".visible = false
		$"../Control/Boss".toggle_status()
	if level_state == 2:
		pass
		#get_tree().change_scene("res://scenes/outro.tscn")
	# when level goal is reached
	if level_state == 3:
		$"../Control/continue_game".visible = true
	# when player clicks on boss and wants to quit
	if current_dialogue == "level_three_wanna_quit":
		$"../Control/continue_game".visible = true
	# if dialogue has been about replaying or resetting
	if current_dialogue == "level_three_restart" or current_dialogue == "level_three_stay":
		reset_level()
	# if dialogue has been about continuing to next level
	if current_dialogue == "level_three_continue":
		next_level()
	current_dialogue = null


func _on_grid_match_made(number_of_tiles, tile_group):
	pass
#	if tile_group.size() > 0 and tile_group[0] == "protester":
#		cut_protesters += 1
#		if cut_protesters == protester_treshold:
#			level_state = 5
#			prompt_end()

func _on_score_keeper_protesters_matched():
	cut_protesters += 1
	if cut_protesters == protester_treshold:
		level_state = 5
		prompt_end()


func _on_score_keeper_level_goal_reached():
	if !is_level_goal_reached and cut_protesters < protester_treshold:
		is_level_goal_reached = true
		level_state = 3
		prompt_end()

func signal_from_scorekeeper():
	pass


func prompt_end():
	var score = $"../score_keeper".score
	var boss = $"../Control/Boss"
	
	$"../grid".can_play = false
	ask_for_grid_pause()
	
	# special case if player is ending the game by getting fired or killing the boss
	if boss.current_dialogue == "hit_boss_dead" or boss.current_dialogue == "hit_boss_fired":
		return
	
	boss.toggle_status()
	
	if level_state == 2:
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_three_wanna_quit.json")
		current_dialogue = "level_three_wanna_quit"
		
	# level goal is reached
	if level_state == 3:
		print("level state is 3 so imma go there")
		if times_played == 0:
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_three_001.json")
			boss.can_talk_to = true
			times_played += 1
		else:
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_three_wanna_quit.json")
			current_dialogue = "level_three_wanna_quit"
	
	# reset
	if level_state == 5:
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_three_restart.json")
		current_dialogue = "level_three_restart"
		# boss.can_talk_to = false
		return


func ask_for_grid_pause():
	if times_paused < 3:
		times_paused += 1
		$"../grid".pause()
		$"../grid_pauser".start()
	elif times_paused == 3:
		times_paused = 0


func reset_level():
	print("---------------")
	print("resetting scene")
	$"../score_keeper".reset_score()
	cut_protesters = 0
	is_level_goal_reached = false
	$"../grid".reset()
	$"../grid".can_play = $"../Control/tool_saw".is_selected
	$"../Control/Boss".toggle_status()
	level_state = 3
	

func next_level():
	get_tree().change_scene("res://scenes/outro.tscn")


func _on_stay_pressed():
	$"../Control/continue_game".visible = false
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_three_stay.json")
	current_dialogue = "level_three_stay"
	level_state = 2


func _on_continue_pressed():
	$"../Control/continue_game".visible = false
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_three_continue.json")
	current_dialogue = "level_three_continue"
	level_state = 2


func _on_grid_pauser_timeout():
	ask_for_grid_pause()

