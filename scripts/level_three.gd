extends Node


# states are: 0 = beginning, 1 = intro done, 2 = gameplay, 3 = goal reached, 4 = replay
var level_state = 0
var is_level_goal_reached = false
const current_level = 3


func _ready():
	get_node("/root/game_data").current_level = current_level
	$"../Control/Boss".current_level = current_level


func _on_DialogueBox_dialog_box_closed():
	level_state += 1
	if level_state == 1:
		$"../Control/input_blocker".visible = false
		#$"../grid".can_play = true
		$"../Control/Boss".toggle_status()
		#$"../Control/timer_text".start_countdown()
	if level_state == 2:
		get_tree().change_scene("res://scenes/outro.tscn")
	if level_state == 3:
		pass
		#$"../Control/continue_game".visible = true
	#if current_dialogue == "level_one_continue":
		#next_level()
	#current_dialogue = null


func _on_score_keeper_level_goal_reached():
	if !is_level_goal_reached:
		is_level_goal_reached = true
		$"../Control/Boss".toggle_status()
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_three_001.json")
