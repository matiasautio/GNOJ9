extends Node2D


export var skip_dialogue = false

export var initial_moves = 10
#export var change_treshold = 5000
var level_tresholds = [5000, 10000, 15000, 20000, 25000, 30000]
var level_index = 0
var orig_pieces = []
export (Array, PackedScene) var extra_pieces

onready var move_keeper = $move_keeper

var has_read_intro = false
var moves_ended = false
var high_score = 0


func _ready():
	if skip_dialogue:
		$Control/input_blocker.visible = false
		$Control/DialogueBoxHolder.visible = false
		$Control/DialogueBoxHolder/DialogueBox/.play_on_start = false
	move_keeper.set_moves(initial_moves)
	high_score = game_data.endless_high_score
	$Control/hi_score.bbcode_text = "[center]" + str(high_score)
	$score_keeper.level_goal = level_tresholds[level_index]
	for piece in $grid.possible_pieces:
		orig_pieces.append(piece)


func add_moves(moves):
	move_keeper.moves_left += moves


func end():
	print("end")
	if $score_keeper.score > high_score:
		high_score = $score_keeper.score
		game_data.endless_high_score = high_score
		$Control/hi_score.bbcode_text = "[center]" + str(high_score)
		game_data.save_progression()
	$Control/DialogueBoxHolder.visible = true
	$Control/DialogueBoxHolder/DialogueBox.trigger_dialogue("res://dialogue/endless_mode/endless_mode_out_of_moves.json")
	


func _on_DialogueBox_dialog_box_closed():
	$Control/input_blocker.visible = false
	if !has_read_intro:
		has_read_intro = true
	else:
		$Control/continue_game.visible = true
	if moves_ended:
		$Control/continue_game.visible = true


func _on_move_keeper_moves_deplenished():
	moves_ended = true
	#end()


func _on_grid_match_made(number_of_tiles, tile_group):
	print(number_of_tiles, " tiles were matched.")
	if number_of_tiles == 4:
		add_moves(1)
	if number_of_tiles == 5:
		add_moves(2)
	if number_of_tiles >= 6:
		add_moves(3)
#	if number_of_tiles >= 7:
#		add_moves(4)


func _on_developer_button_pressed():
	$Control/DialogueBoxHolder.visible = true
	if !has_read_intro:
		$Control/DialogueBoxHolder/DialogueBox.trigger_dialogue("res://dialogue/endless_mode/endless_mode_info.json")
	else:
		$Control/DialogueBoxHolder/DialogueBox.trigger_dialogue("res://dialogue/endless_mode/endless_mode_wanna_quit.json")


func hide_continue_ui():
	$Control/continue_game.visible = false


func _on_stay_pressed():
	hide_continue_ui()
	$score_keeper.reset_score()
	$move_keeper.reset_moves()
	$grid.possible_pieces.clear()
	for piece in orig_pieces:
		$grid.possible_pieces.append(piece)
	$grid.reset()
	moves_ended = false


func _on_return_to_menu_pressed():
	var _x = get_tree().change_scene("res://scenes/main_menu.tscn")


func _on_score_keeper_level_goal_reached():
	level_index += 1
	$score_keeper.level_goal = level_tresholds[level_index]
	if level_index <= extra_pieces.size():
		$grid.possible_pieces.append(extra_pieces[level_index-1])


func _on_grid_grid_stopped():
	if moves_ended:
		end()


func _on_PointsMap_pressed():
	$Control/PointMap.visible = true


func _on_Return_pressed():
	$Control/PointMap.visible = false
