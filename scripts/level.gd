extends Node

class_name Level

# 0 = score, 1 = moves, 2 = timer
export var level_type = 0
export var score_threshold = 10000
export var moves = 10

# 0 = beginning, 1 = intro done, 2 = gameplay, 3 = goal reached, 4 = replay, 5 = protester fail, 6 = cop fail
var level_state = 0
var gameplay_state = 2 # depends on scene?
var is_level_goal_reached = false
export var current_level : int = 0
export var next_level_scene = ""

export var stay_dialogue = ""
export var continue_dialogue = ""
export var wanna_quit_dialogue = ""
export var end_of_level_dialogue = ""
export var restart_dialogue = ""

var current_dialogue

var cut_protesters = 0
const protester_treshold = 10
export var protester_treshold_met_dialogue = "res://dialogue/level_three_restart.json"
var cut_cops = 0
var cop_treshold = 10
export var cop_treshold_met_dialogue = "res://dialogue/cop_triggered.json"
export var cop_scene = "res://scenes/day_two/cop_raid.tscn"

# looping
var times_played = 0

# grid pause hack
var times_paused = 0

# scoring
var highest_score = 0

# level specific logic
var has_boss_reacted = false


func _ready():
	get_node("/root/game_data").current_level = current_level
	$"../Control/Boss".current_level = current_level


func _on_DialogueBox_dialog_box_closed():
	if level_state == 0:
		level_state = gameplay_state
		if $"../Control/Boss".visible:
			$"../Control/Boss".animation = "away"
		if $"../Control/Cop".visible:
			$"../Control/Cop".animation = "away"
		if $"../Control/Protester".visible:
			$"../Control/Protester".animation = "away"
		$"../Control/input_blocker".visible = false
	if level_state == 6:
		var _x = get_tree().change_scene(cop_scene)


func _on_DialogueBox_next_phrase_requested():
	pass


func _on_grid_match_made(_number_of_tiles, _tile_group):
	if _tile_group == "protester":
		cut_protesters += _number_of_tiles
		if cut_protesters >= protester_treshold:
			level_state = 5
			prompt_end()
	if _tile_group == "cop":
		cut_cops += _number_of_tiles
		game_data.cops_killed += _number_of_tiles
		print(cut_cops)
		if cut_cops >= cop_treshold:
			level_state = 6
			prompt_end()
	check_tiles_after_match()


func _on_score_keeper_protesters_matched():
	pass


func _on_move_keeper_moves_deplenished():
	if level_type == 1:
		prompt_end()


func _on_score_keeper_level_goal_reached():
	if level_type == 0:
		prompt_end()


func signal_from_scorekeeper():
	pass


func prompt_end():
	var _score = $"../score_keeper".score
	var boss = $"../Control/Boss"
	
	$"../grid".can_play = false
	ask_for_grid_pause()
	
	# special case if player is ending the game by getting fired or killing the boss
	if boss.current_dialogue == "hit_boss_dead" or boss.current_dialogue == "hit_boss_fired":
		return
	
	boss.toggle_status()
	
	if level_state == 2:
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(wanna_quit_dialogue)
		current_dialogue = "wanna_quit"
		
	# level goal is reached
	if level_state == 3:
		print("level state is 3 so imma go there")
		if times_played == 0:
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(end_of_level_dialogue)
			boss.can_talk_to = true
			times_played += 1
		else:
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(wanna_quit_dialogue)
			current_dialogue = "wanna_quit"
	
	# reset
	if level_state == 5:
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(protester_treshold_met_dialogue)
		current_dialogue = "restart"
		# boss.can_talk_to = false
		return
	
	# go to cop scene
	if level_state == 6:
		if $"../Control/Cop".visible:
			$"../Control/Cop".animation = "default"
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(cop_treshold_met_dialogue)
		current_dialogue = "restart"
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
	$"../move_keeper".reset_moves()
	cut_protesters = 0
	cut_cops = 0
	is_level_goal_reached = false
	$"../grid".reset()
	$"../grid".can_play = $"../Control/tool_saw".is_selected
	$"../Control/Boss".toggle_status()
	#level_state = 3
	

func next_level():
	game_data.protesters_killed = cut_protesters
	game_data.current_score += highest_score
	var _x = get_tree().change_scene(next_level_scene)


func _on_stay_pressed():
	$"../Control/continue_game".visible = false
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(stay_dialogue)
	#current_dialogue = "level_three_stay"
	level_state = gameplay_state


func _on_continue_pressed():
	$"../Control/continue_game".visible = false
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(continue_dialogue)
	#current_dialogue = "level_three_continue"
	level_state = gameplay_state


func _on_grid_pauser_timeout():
	ask_for_grid_pause()


func check_tiles_after_match():
	pass
	
