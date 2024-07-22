extends Node2D


var end_game_value = 6
var current_dialogue_value = 0


func _on_DialogueBox_next_phrase_requested():
	current_dialogue_value += 1
	# print(current_dialogue_value)
	if current_dialogue_value == end_game_value:
		$FadeOut/AnimationPlayer.play("fade_out")
		game_data.calculate_score()


func load_next_scene(anim_name):
	var _x = get_tree().change_scene("res://scenes/dream.tscn")
