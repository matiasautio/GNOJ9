extends Node

signal moves_deplenished

onready var moves_text = $"../Control/timer_text"
export var number_of_moves = 10
var moves_left


# Called when the node enters the scene tree for the first time.
func _ready():
	moves_left = number_of_moves
	if number_of_moves == -1:
		moves_text.bbcode_text = "[center]∞[/center]"
	else:
		moves_text.bbcode_text = "[center]" + String(moves_left) + "[/center]"


func reset_moves():
	moves_left = number_of_moves
	if number_of_moves == -1:
		moves_text.bbcode_text = "[center]∞[/center]"
	else:
		moves_text.bbcode_text = "[center]" + String(moves_left) + "[/center]"


func _on_grid_swap_succesful():
	if moves_left != -1:
		moves_left -= 1
		moves_text.bbcode_text = "[center]" + String(moves_left) + "[/center]"
		if moves_left == 0:
			emit_signal("moves_deplenished")
