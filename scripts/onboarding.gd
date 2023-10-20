extends Node

var index = 0
var score = 0
var previous_score = 0


func _on_grid_swap_succesful():
	index += 1
	if index == 1:
		$"../hand".visible = false
		$"../BackgroundColor/guide_text/AnimationPlayer".play("increase_scale")
		$"../BackgroundColor/guide_text".bbcode_text = "[center][wave]Earn points!"
		$"../BackgroundColor/score_ui".visible = true
		$"../BackgroundColor/score_ui/AnimationPlayer".play("increase_scale")
	elif index == 2:
		$"../BackgroundColor/guide_text".bbcode_text = "[center][wave]Limited moves!"
		$"../BackgroundColor/guide_text/AnimationPlayer".play("increase_scale")
		$"../BackgroundColor/score_ui".visible = false
		$"../BackgroundColor/moves_ui/AnimationPlayer".play("increase_scale")
	elif index == 3:
		$"../BackgroundColor/moves_ui/timer_text".bbcode_text = "[center]0[/center]"
		$delay.start()


func increase_score():
	if previous_score + 10 < score:
		$"../score_incrementer".start(0.01)
	else:
		previous_score = score
		$"../BackgroundColor/score_ui/score".bbcode_text = "[center]" + str(previous_score) + "[/center]"


func _on_grid_match_made(number_of_tiles, tile_group):
	score += 70 * number_of_tiles
	if index == 1:
		increase_score()


func _on_AnimationPlayer_animation_finished(anim_name):
	increase_score()


func _on_score_incrementer_timeout():
	previous_score += 10
	$"../BackgroundColor/score_ui/score".bbcode_text = "[center]" + str(previous_score) + "[/center]"
	increase_score()


func _on_delay_timeout():
	if index == 3:
		$"../BackgroundColor/guide_text".bbcode_text = "[center][wave]Well done!"
		$"../BackgroundColor/guide_text/AnimationPlayer".play("increase_scale")
		$"../BackgroundColor/moves_ui".visible = false
		$"../BackgroundColor/start_job/AnimationPlayer".play("increase_scale_larger")
	elif index < 0:
		var x = get_tree().change_scene("res://scenes/intro.tscn")

func _on_start_job_pressed():
	$"../button_feedback".play()
	var pieces = $"../grid".get_children()
	for child in pieces:
		if child.has_method("cut"):
			child.cut()
	index = -100
	$delay.start(1)
