extends Node2D

export (Array, PackedScene) var possible_pieces = []
var used_pieces = []
export var sydan_piece : PackedScene


func _ready():
	for piece in possible_pieces:
		used_pieces.append(piece)
	used_pieces.remove(randi() % used_pieces.size())
	used_pieces.append(sydan_piece)
	for piece in used_pieces:
		$grid.possible_pieces.append(piece)
	$grid.spawn_pieces()


func _on_move_keeper_moves_deplenished():
	used_pieces.clear()
	for piece in possible_pieces:
		used_pieces.append(piece)
	used_pieces.remove(randi() % used_pieces.size())
	used_pieces.append(sydan_piece)
	$grid.possible_pieces.clear()
	for piece in used_pieces:
		$grid.possible_pieces.append(piece)
	$grid.reset()
	$score_keeper.reset_score()
	$move_keeper.reset_moves()
