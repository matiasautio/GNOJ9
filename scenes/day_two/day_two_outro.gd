extends Node2D


func _ready():
	game_data.calculate_score()


func _on_DialogueBox_dialog_box_closed():
	var _x = get_tree().change_scene("res://scenes/day_two/day_two_dream.tscn")
	game_data.reset_current_score()
