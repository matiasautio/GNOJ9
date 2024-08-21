extends Node


# holds the story flow logics for level one

# states are: 0 = beginning, 1 = intro done, 2 = gameplay, 3 = goal reached, 4 = replay
var level_state = 0
var tool_is_clicked_first_time = false
var is_level_goal_reached = false

var current_dialogue = null
const current_level = 1

var boss_just_hurt = false

# looping
var times_played = 0

# grid pause hack
var times_paused = 0

# scoring
var highest_score = 0


func _ready():
	get_node("/root/game_data").current_level = current_level
	$"../Control/Boss".current_level = self


func _on_tool_button_button_down():
	if !tool_is_clicked_first_time:
		tool_is_clicked_first_time = true
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_one_001.json")

func level_goal_reached():
	if !is_level_goal_reached:
		is_level_goal_reached = true
		level_state = 3
		$"../Control/Boss".toggle_status()
		if times_played == 0:
			$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_one_002.json")
			current_dialogue = "level_one_002"
		else:
			prompt_end()
		times_played += 1
		if $"../score_keeper".score > highest_score:
			highest_score = $"../score_keeper".score


func prompt_end():
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_one_wanna_quit.json")
	current_dialogue = "level_one_wanna_quit"


func _on_score_keeper_level_goal_reached():
	level_goal_reached()
	ask_for_grid_pause()


func _on_DialogueBox_dialog_box_closed():
	level_state += 1
	if level_state == 1:
		$"../Control/input_blocker".visible = false
	if level_state == 2:
		$"../grid".can_play = $"../Control/tool_saw".is_selected
		$"../Control/Boss".toggle_status()
	# caring about level state numbers ends here
	if current_dialogue == "level_one_002":
		display_continue_screen()
	if current_dialogue == "level_one_continue":
		next_level()
	if current_dialogue == "level_one_stay":
		reset()
	if current_dialogue == "level_one_wanna_quit":
		display_continue_screen()
	current_dialogue = null


func display_continue_screen():
	$"../Control/continue_game".visible = true


func _on_stay_button_down():
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_one_stay.json")
	$"../Control/continue_game".visible = false
	$"../Control/Boss".can_talk_to = true
	current_dialogue = "level_one_stay"


func _on_continue_button_down():
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_one_continue.json")
	$"../Control/continue_game".visible = false
	$"../Control/Boss".can_talk_to = true
	current_dialogue = "level_one_continue"


func reset():
	$"../grid".reset()
	$"../grid".can_play = $"../Control/tool_saw".is_selected
	$"../score_keeper".reset_score()
	is_level_goal_reached = false
	$"../Control/tool_saw".grid_stopped()


func next_level():
	game_data.current_score += highest_score
	var _x = get_tree().change_scene("res://scenes/game_window_two.tscn")


func ask_for_grid_pause():
	if times_paused < 3:
		times_paused += 1
		$"../grid".pause()
		$"../grid_pauser".start()
	elif times_paused == 3:
		times_paused = 0


func _on_grid_pauser_timeout():
	ask_for_grid_pause()
