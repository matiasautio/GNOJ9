extends Node2D


export var skip_dialogue = false

export var initial_moves = 5
#export var change_treshold = 5000
var level_tresholds = [5000, 10000, 15000, 20000, 25000, 30000]
var point_increase = 5000
var level_index = 0
var orig_pieces = []
export (Array, PackedScene) var extra_pieces
var tile_index = 0

onready var move_keeper = $move_keeper

var has_read_intro = false
var moves_ended = false
var high_score = 0
var new_highscore = false


func _ready():
	if skip_dialogue:
		$Control/input_blocker.visible = false
		$Control/DialogueBoxHolder.visible = false
		$Control/DialogueBoxHolder/DialogueBox/.play_on_start = false
	move_keeper.set_moves(initial_moves)
	high_score = game_data.endless_high_score
	$Control/hi_score.bbcode_text = "[center]" + str(high_score)
	$score_keeper.level_goal = point_increase#level_tresholds[level_index]
	for piece in $grid.possible_pieces:
		orig_pieces.append(piece)
	move_keeper.is_used = true


func add_moves(moves):
	move_keeper.moves_left += moves


func end():
	print("end")
	if $score_keeper.score > high_score:
		high_score = $score_keeper.score
		game_data.endless_high_score = high_score
		$Control/hi_score.bbcode_text = "[center]" + str(high_score)
		game_data.save_progression()
		new_highscore = true
	$Control/DialogueBoxHolder.visible = true
	if new_highscore:
		$Control/DialogueBoxHolder/DialogueBox.trigger_dialogue("res://dialogue/endless_mode/endless_mode_new_highscore.json")
	else:
		$Control/DialogueBoxHolder/DialogueBox.trigger_dialogue("res://dialogue/endless_mode/endless_mode_out_of_moves.json")
	


func _on_DialogueBox_dialog_box_closed():
	$Control/input_blocker.visible = false
	# Beginning of the game
	if !moves_ended:
		if !has_read_intro:
			has_read_intro = true
		else:
			$Control/continue_game.visible = true
	# Player has ran out of moves
	else:
		if new_highscore:
			new_highscore = false
			$Control/DialogueBoxHolder/DialogueBox.trigger_dialogue("res://dialogue/endless_mode/endless_mode_out_of_moves.json")
		else:
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
	$score_keeper.level_goal = point_increase
	$move_keeper.reset_moves()
	remove_rocks()
	$grid.possible_pieces.clear()
	for piece in orig_pieces:
		$grid.possible_pieces.append(piece)
	$grid.reset()
	moves_ended = false
	level_index = 0


func _on_return_to_menu_pressed():
	var _x = get_tree().change_scene("res://scenes/main_menu.tscn")


func _on_score_keeper_level_goal_reached():
	level_index += 1
	$score_keeper.level_goal += point_increase #level_tresholds[level_index]
	# add juniper trees
	if level_index == 1:
		add_tile(0)
	# add rocks
	if level_index == 2:
		add_rock_tiles()
	# add protesters
	if level_index == 3:
		add_tile(1)
	# add more rocks
	if level_index == 4:
		#add_empty_spaces()
		remove_rocks()
		add_rock_tiles()
	# add cops
	if level_index == 5:
		#remove_rocks()
		add_tile(2)
	# currently the endless mode ends here
	# in the future the could be a forest fire or somehing like that!
	# add more rocks
	#if level_index >= 6:
		#add_rock_tiles()


func add_tile(index):
	$grid.possible_pieces.append(extra_pieces[index])


func add_empty_spaces():
	for _i in range(level_index + 3):
		var tile_pos = Vector2(int(rand_range(0,7)), int(rand_range(0,9)))
		$grid.empty_spaces.append(tile_pos)
		var tile_to_remove = $grid.all_pieces[tile_pos.x][tile_pos.y]
		#print(tile_pos)
		#print(tile_to_remove)
		if tile_to_remove != null:
			tile_to_remove.queue_free()
		$grid.all_pieces[tile_pos.x][tile_pos.y] = null
		# also remove from array


func add_rock_tiles():
	for _i in range(level_index + 5):
		var tile_pos = Vector2(int(rand_range(0,7)), int(rand_range(0,9)))
		$grid.concrete_spaces.append(tile_pos)
		var tile_to_remove = $grid.all_pieces[tile_pos.x][tile_pos.y]
		#print(tile_pos)
		#print(tile_to_remove)
		if tile_to_remove != null:
			tile_to_remove.queue_free()
		$grid.all_pieces[tile_pos.x][tile_pos.y] = null
	# Does this spawn a new rock on top the ones already in game?
	$grid.spawn_concrete()


func remove_rocks():
	# Let's leave the rocks in place to further mess up the game!
	$grid.concrete_spaces.clear()
	for i in range($grid/concrete_holder.concrete_pieces.size()):
		for rock in $grid/concrete_holder.concrete_pieces[i]:
			if rock != null:
				rock.queue_free()
	$grid/concrete_holder.concrete_pieces.clear()
				#$grid/concrete_holder.concrete_pieces[i].erase(rock)


func _on_grid_grid_stopped():
	if moves_ended:
		end()


func _on_PointsMap_pressed():
	$Control/PointMap.visible = true


func _on_Return_pressed():
	$Control/PointMap.visible = false
