extends Node


# holds the story flow logics for level one

# states are: 0 = beginning, 1 = intro done, 2 = gameplay, 3 = goal reached, 4 = replay
var level_state = 0
var tool_is_clicked_first_time = false
var is_level_goal_reached = false

var current_dialogue = null


func _ready():
	pass # Replace with function body.
	

#func _process(delta):
#	pass


func _on_tool_button_button_down():
	if !tool_is_clicked_first_time:
		tool_is_clicked_first_time = true
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_one_001.json")

func level_goal_reached():
	if !is_level_goal_reached:
		is_level_goal_reached = true
		$"../Control/Boss".toggle_status()
		$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_one_002.json")


func _on_score_keeper_level_goal_reached():
	level_goal_reached()


func _on_DialogueBox_dialog_box_closed():
	print("box closed")
	level_state += 1
	if level_state == 1:
		$"../Control/input_blocker".visible = false
	if level_state == 2:
		$"../grid".can_play = true
		$"../Control/Boss".toggle_status()
	if level_state == 3:
		$"../Control/continue_game".visible = true
	if current_dialogue == "level_one_continue":
		next_level()
	current_dialogue = null


func _on_stay_button_down():
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_one_stay.json")
	$"../Control/continue_game".visible = false
	$"../Control/Boss".can_talk_to = true


func _on_continue_button_down():
	$"../Control/DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_one_continue.json")
	$"../Control/continue_game".visible = false
	$"../Control/Boss".can_talk_to = true
	current_dialogue = "level_one_continue"


func next_level():
	get_tree().change_scene("res://scenes/game_window.tscn")
