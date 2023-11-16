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
	$laku_curtains.get_node("curtains_animation").connect("animation_finished", self, "_on_curtains_animation_animation_finished")
	$laku_curtains.get_node("curtains_animation").play("curtains_open")


func _on_move_keeper_moves_deplenished():
	$end_delay.start()
	$grid.can_play = false
	

func _on_curtains_animation_animation_finished(anim_name):
	if anim_name == "curtains_close":
		$Control/end_stuff.visible = false
		$grid.visible = true
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
		$grid.can_play = true
		$laku_curtains.get_node("curtains_animation").play("curtains_open")


func _on_end_delay_timeout():
	$grid.visible = false
	$Control/end_stuff/text/end_score.text = str($score_keeper.score) + " pistettä"
	$Control/end_stuff.visible = true
	$Control/end_stuff/AnimationPlayer.play("text_appears")
	# checking the hi score
	# new hi score!
	if $score_keeper.score > $hi_score.hi_score:
		$Control/end_stuff/hiscore_text/hiscore_text.text = "Uusi paras tulos!"
		$hi_score.hi_score = $score_keeper.score
		$hi_score.save_progression()
	# old score is higher
	else:
		$Control/end_stuff/hiscore_text/hiscore_text.text = "Paras tuloksesi on:"
	$Control/end_stuff/hiscore_text/hiscore_score.text = str($hi_score.hi_score) + " pistettä"


func _on_play_pressed():
	$laku_curtains.get_node("curtains_animation").play("curtains_close")
