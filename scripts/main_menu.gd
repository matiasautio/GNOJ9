extends Node2D


onready var game_data = get_node("/root/game_data")


func _ready():
	if game_data.current_level > 1:
		$BackgroundColor/Control/start_game.visible = false
		$BackgroundColor/Control/continue.visible = true
		$BackgroundColor/Control/restart.visible = true
	# game_data.boss_health = game_data.orig_boss_health


func _on_start_game_button_down():
	$BackgroundColor/Control/piece/AnimatedSprite.play("cut")
	$AudioStreamPlayer.play()


func _on_AnimatedSprite_animation_finished():
	$start_delay.start()


func _on_start_delay_timeout():
	if game_data.current_level == 1:
		var _x = get_tree().change_scene("res://scenes/intro.tscn")
	elif game_data.current_level == 2:
		var _x = get_tree().change_scene("res://scenes/day_two/day_two_one.tscn")


func _on_credits_button_down():
	$Credits.visible = true


func _on_return_button_down():
	$Credits.visible = false


func _on_continue_button_down():
	$start_delay.start()


func _on_restart_button_down():
	game_data.reset_progression()
	$start_delay.start()
