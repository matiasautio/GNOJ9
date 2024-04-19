extends Node2D


func _ready():
	$Background.play()


func _on_DialogueBox_dialog_box_closed():
	var _x = get_tree().change_scene("res://scenes/day_two/day_two_level_three_dead_cop.tscn")
