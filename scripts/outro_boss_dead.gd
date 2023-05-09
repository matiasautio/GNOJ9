extends Node2D


var end_game_value = 5
var current_dialogue_value = 0

func _on_DialogueBox_next_phrase_requested():
	current_dialogue_value += 1
	# print(current_dialogue_value)
	if current_dialogue_value == end_game_value:
		var _x = get_tree().change_scene("res://scenes/main_menu.tscn")
