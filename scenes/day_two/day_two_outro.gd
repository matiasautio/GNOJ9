extends Node2D

var phrase_index = 0
var enough_points_dialogue = "res://dialogue/day_two/outro_enough_points.json"
var too_few_points = "res://dialogue/day_two/outro_not_enough_points.json"

# this is used to avoid the problem that triggering a new dialogue via
# a keyword within the text causes, in which a phrase from the triggered dialogue
# is omitted. When the previous dialogue ends, it closes the box but the triggered
# dialogue openes it again
var closed_index = 0


func _ready():
	game_data.calculate_score()


func _on_DialogueBox_dialog_box_closed():
	if closed_index == 1:
		$FadeOut/AnimationPlayer.play("fade_out")
		game_data.reset_current_score()
	closed_index += 1


func _on_DialogueBox_next_phrase_requested():
	#print(phrase_index)
	if phrase_index == 1:
		if game_data.total_score < 10000:
			$"DialogueBoxHolder/DialogueBox".trigger_dialogue(too_few_points)
		else:
			$"DialogueBoxHolder/DialogueBox".trigger_dialogue(enough_points_dialogue)
	phrase_index += 1


func load_next_scene(_anim_name):
	var _x = get_tree().change_scene("res://scenes/day_two/day_two_dream.tscn")
