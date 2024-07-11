extends Node2D


export var skip_dialogue = false

export var initial_moves = 10

onready var move_keeper = $move_keeper


func _ready():
	if skip_dialogue:
		$Control/input_blocker.visible = false
		$Control/DialogueBoxHolder.visible = false
		$Control/DialogueBoxHolder/DialogueBox/.play_on_start = false
	move_keeper.number_of_moves = initial_moves


func add_moves(moves):
	move_keeper.moves_left += moves


func end():
	pass


func _on_DialogueBox_dialog_box_closed():
	$Control/input_blocker.visible = false


func _on_move_keeper_moves_deplenished():
	end()


func _on_grid_match_made(number_of_tiles, tile_group):
	print(number_of_tiles, " tiles were matched.")
	if number_of_tiles == 4:
		add_moves(3)
	if number_of_tiles == 5:
		add_moves(5)
	if number_of_tiles == 6:
		add_moves(8)
	if number_of_tiles >= 6:
		add_moves(10)


func _on_developer_button_pressed():
	$Control/DialogueBoxHolder.visible = true
	$Control/DialogueBoxHolder/DialogueBox.trigger_dialogue("res://dialogue/endless_mode/endless_mode_info.json")
