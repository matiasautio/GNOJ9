extends Node2D


var start_game_value = 4
var current_dialogue_value = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DialogueBox_next_phrase_requested():
	current_dialogue_value += 1
	#print(current_dialogue_value)
	if current_dialogue_value == start_game_value:
		var _x = get_tree().change_scene("res://scenes/game_window.tscn")
