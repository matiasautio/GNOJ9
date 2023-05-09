extends Node2D

func _on_DialogueBox_dialog_box_closed():
	var _x = get_tree().change_scene("res://scenes/main_menu.tscn")
