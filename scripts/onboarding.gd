extends Node

var index = 0
var score = 0
var previous_score = 0
var grid


func _ready():
	grid = $"../grid"
	grid.onboarding = true


func spawn_pieces():
	grid.spawn_specific_piece(1,0,3)
	grid.spawn_specific_piece(1,0,2)
	grid.spawn_specific_piece(0,0,1)
	grid.spawn_specific_piece(2,0,0)
	# second column
	grid.spawn_specific_piece(1,1,3)
	grid.spawn_specific_piece(0,1,2)
	grid.spawn_specific_piece(2,1,1)
	grid.spawn_specific_piece(0,1,0)
	# third column
	grid.spawn_specific_piece(2,2,3)
	grid.spawn_specific_piece(1,2,2)
	grid.spawn_specific_piece(1,2,1)
	grid.spawn_specific_piece(2,2,0)
	# fourth column
	grid.spawn_specific_piece(0,3,3)
	grid.spawn_specific_piece(0,3,2)
	grid.spawn_specific_piece(2,3,1)
	grid.spawn_specific_piece(1,3,0)


func _on_grid_swap_succesful():
	index += 1
	if index == 1:
		$"../hand".visible = false
		$"../BackgroundColor/ScaleHelper/guide_text/AnimationPlayer".play("increase_scale")
		$"../BackgroundColor/ScaleHelper/guide_text".bbcode_text = "[center][wave]Earn points!"
		$"../BackgroundColor/score_ui".visible = true
		$"../BackgroundColor/score_ui/AnimationPlayer".play("increase_scale")
	elif index == 2:
		$"../BackgroundColor/ScaleHelper/guide_text".bbcode_text = "[center][wave]Limited moves!"
		$"../BackgroundColor/ScaleHelper/guide_text/AnimationPlayer".play("increase_scale")
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
		$"../BackgroundColor/ScaleHelper/guide_text".bbcode_text = "[center][wave]Well done!"
		$"../BackgroundColor/ScaleHelper/guide_text/AnimationPlayer".play("increase_scale")
		$"../BackgroundColor/moves_ui".visible = false
		$"../BackgroundColor/start_job/AnimationPlayer".play("increase_scale_larger")
	elif index < 0:
		var x = get_tree().change_scene("res://scenes/intro.tscn")


func start_job_button_became_visible(anim_name):
	#print(anim_name)
	if anim_name == "increase_scale_larger":
		$"../BackgroundColor/start_job/AnimationPlayer".play("pump_scale")
		$"../hand".visible = true
		$"../hand".position = Vector2(434, 789)
		$"../hand/AnimationPlayer".play("start_game")
		#377
		#739


func _on_start_job_pressed():
	$"../button_feedback".play()
	var pieces = $"../grid".get_children()
	for child in pieces:
		if child.has_method("cut"):
			child.cut()
	index = -100
	$delay.start(1)
