extends Node

class_name Level

# 0 = score, 1 = moves, 2 = timer
export var level_type = 0
export var score_threshold = 10000
export var level_time_limit = 30
# -1 is infinite moves
export var moves = 10

# 0 = beginning, 1 = intro done, 2 = gameplay, 3 = goal reached, 4 = replay, 5 = protester fail, 6 = cop fail
# 10 = end level
var level_state = 0
var gameplay_state = 2 # depends on scene?
var is_level_goal_reached = false
export var current_day : int = 0
#export var current_level_name = ""
export (String, MULTILINE) var next_level_scene = ""
const main_menu = "res://scenes/main_menu.tscn"

export (String, MULTILINE) var stay_dialogue = ""
export (String, MULTILINE) var continue_dialogue = ""
export (String, MULTILINE) var wanna_quit_dialogue = ""
export (String, MULTILINE) var end_of_level_dialogue = ""
export (String, MULTILINE) var restart_dialogue = ""
export (String, MULTILINE) var deadlock_dialogue = "res://dialogue/special/boss_deadlock_reaction.json"

var current_dialogue

export var ignore_protestor_safety = false
var cut_protesters = 0
const protester_treshold = 10
export (String, MULTILINE) var protester_treshold_met_dialogue = "res://dialogue/level_three_restart.json"
export var ignore_cop_safety = false
var cut_cops = 0
var cop_treshold = 10
export (String, MULTILINE) var cop_treshold_met_dialogue = "res://dialogue/cop_triggered.json"
export (String, MULTILINE) var cop_scene = "res://scenes/day_two/cop_raid.tscn"

# boss
onready var boss = $"../Control/Boss"
var boss_just_hurt = false

# looping
var times_played = 0

# grid pause hack
var times_paused = 0

# scoring
#var highest_score = 0
var level_highscores = Vector2.ZERO

# level specific logic
var has_boss_reacted = false


func _ready():
	get_node("/root/game_data").current_level = current_day
	boss.current_level = self
	if level_type == 0:
		$"../score_keeper".level_goal = score_threshold
	elif level_type == 1:
		#$"../move_keeper".number_of_moves = moves
		$"../move_keeper".set_moves(moves)
	elif level_type == 2:
		$"../Control/timer_text".level = self
		$"../Control/timer_text".countdown_length = level_time_limit
		#$"../Control/timer_text".init()
	other_init()


func other_init():
	pass


func _on_DialogueBox_dialog_box_closed():
	if level_state == 0:
		level_state = 2
		if boss.visible:
			boss.animation = "away"
		if $"../Control/Cop" != null and $"../Control/Cop".visible:
			$"../Control/Cop".animation = "away"
			$"../Control/Cop".visible = false
		if $"../Control/Protester" != null and $"../Control/Protester".visible:
			$"../Control/Protester".animation = "away"
			$"../Control/Protester".visible = false
		$"../Control/input_blocker".visible = false
		if level_type == 2:
			$"../Control/timer_text".start_countdown()
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
		reset_level()
	# Too many protesters were cut down, level resets
	elif level_state == 5:
		reset_level()
	elif level_state == 6:
		#game_data.previous_level_name = current_level_name
		var _x = get_tree().change_scene(cop_scene)
	elif level_state == 10:
		next_level()


func _on_DialogueBox_next_phrase_requested():
	pass


# Generally used to check if too many protesters or cops are cut down
func _on_grid_match_made(_number_of_tiles, _tile_group):
	#print(_number_of_tiles, _tile_group)
	# Only add the police and protesters to cut down if the saw was used
	if game_data.get_node("player_status").current_tool == 1:
		if _tile_group == "protester":
			cut_protesters += _number_of_tiles
			if cut_protesters >= protester_treshold and !ignore_protestor_safety:
				level_state = 5
				prompt_end()
		if _tile_group == "cop":
			cut_cops += _number_of_tiles
			game_data.cops_killed += _number_of_tiles
			#print(cut_cops)
			if cut_cops >= cop_treshold and !ignore_cop_safety:
				level_state = 6
				prompt_end()
		#print(cut_cops)
		check_tiles_after_match()


func _on_score_keeper_protesters_matched():
	pass


func _on_move_keeper_moves_deplenished():
	print("moves deplenished")
	#_on_grid_deadlocked()
	if level_type == 1:
		level_state = 3
		prompt_end()


func _on_score_keeper_level_goal_reached():
	print("Level goal reached!")
	if level_type == 0:
		level_state = 3
		prompt_end()


func signal_from_scorekeeper():
	pass


#func update_score(new_score):
#	if new_score > highest_score:
#		highest_score = new_score


func prompt_end():
	#level_highscores = $"../score_keeper".get_highscores()
	#update_score(scores)
	#var boss = $"../Control/Boss"
	
	$"../grid".can_play = false
	ask_for_grid_pause()
	
	# special case if player is ending the game by getting fired or killing the boss
	if boss.current_dialogue == "hit_boss_dead" or boss.current_dialogue == "hit_boss_fired":
		return
	
	boss.toggle_status()
	
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
	if level_state == 3:
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
	if level_type == 1:
		$"../move_keeper".number_of_moves = moves
		$"../move_keeper".reset_moves()
	elif level_type == 2:
		$"../Control/timer_text".countdown_length = level_time_limit
		$"../Control/timer_text".init()
		$"../Control/timer_text".start_countdown()
	cut_protesters = 0
	cut_cops = 0
	is_level_goal_reached = false
	$"../grid".reset()
	$"../grid".can_play = true
	$"../Control/tool_saw".grid_stopped()
	#$"../Control/tool_saw".is_selected
	#$"../Control/Boss".toggle_status()
	#level_state = 3
	

func next_level():
	level_highscores = $"../score_keeper".get_highscores()
	game_data.protesters_killed = cut_protesters
	game_data.current_score += level_highscores.x
	game_data.current_good_guys_score += level_highscores.y
	print(level_highscores)
	var _x = get_tree().change_scene(next_level_scene)


func _on_stay_pressed():
	$"../Control/continue_game".visible = false
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(stay_dialogue)
	#current_dialogue = "level_three_stay"
	level_state = 4


func _on_continue_pressed():
	$"../Control/continue_game".visible = false
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(continue_dialogue)
	#current_dialogue = "level_three_continue"
	level_state = 10


func _on_grid_pauser_timeout():
	ask_for_grid_pause()


func check_tiles_after_match():
	pass
	

func _on_grid_deadlocked():
	# If the level is timer based, just let time run out lol
	if level_type == 2:
		return
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue(deadlock_dialogue)
	# hack to show boss
	boss.is_present = false
	boss.toggle_status()
	level_state = 3
