extends Node2D


var end_game_value = 4
var current_dialogue_value = 0


func _on_DialogueBox_next_phrase_requested():
	current_dialogue_value += 1
	# print(current_dialogue_value)
	if current_dialogue_value == end_game_value:
		var _x = get_tree().change_scene("res://scenes/day_two/day_two_level_one.tscn")


func fader(_anim_name):
	if _anim_name == "fade_in":
		$DialogueBoxHolder/DialogueBox.start_dialogue()
	#if _anim_name == "fade_out":
		#var _scene = get_tree().change_scene(next_scene)
