extends Node2D


export var use_tape_tool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if use_tape_tool:
		game_data.get_node("player_status").current_tool = 2


func _input(event):
	if event.is_action_pressed("ui_down"):
		game_data.get_node("player_status").current_tool = 2
	if event.is_action_pressed("ui_up"):
		game_data.get_node("player_status").current_tool = 1
