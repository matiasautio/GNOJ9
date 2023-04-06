extends Node2D


var end_game_value = 5
var current_dialogue_value = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DialogueBox_next_phrase_requested():
	current_dialogue_value += 1
	print(current_dialogue_value)
	if current_dialogue_value == end_game_value:
		get_tree().change_scene("res://scenes/main_menu.tscn")
