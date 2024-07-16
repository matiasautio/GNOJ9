extends Node2D

var phrase_index = 0
var enough_points_dialogue = "res://dialogue/day_two/outro_enough_points.json"
var too_few_points = "res://dialogue/day_two/outro_not_enough_points.json"


func _ready():
	game_data.calculate_score()


func _on_DialogueBox_dialog_box_closed():
	var _x = get_tree().change_scene("res://scenes/day_two/day_two_dream.tscn")
	game_data.reset_current_score()


func _on_DialogueBox_next_phrase_requested():
	#print(phrase_index)
	if phrase_index == 1:
		if game_data.total_score < 5000:
			$"DialogueBoxHolder/DialogueBox".trigger_dialogue(too_few_points)
		else:
			$"DialogueBoxHolder/DialogueBox".trigger_dialogue(enough_points_dialogue)
	phrase_index += 1
