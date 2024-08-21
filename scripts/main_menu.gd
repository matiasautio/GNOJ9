extends Node2D


onready var game_data = get_node("/root/game_data")
var go_to_endless_mode = false

# Buttons
onready var continue_button = $BackgroundColor/Control/VBoxContainer/continue
onready var restart_button = $BackgroundColor/Control/VBoxContainer/restart
onready var start_game_button = $BackgroundColor/Control/VBoxContainer/start_game
onready var endless_mode_button = $BackgroundColor/Control/VBoxContainer/endless_mode
onready var credits_button = $BackgroundColor/Control/VBoxContainer/credits

# Texts
onready var continue_button_text = $BackgroundColor/Control/VBoxContainer/continue/text

func _ready():
	game_data.load_saved_progression()
	var current_level = game_data.current_level
	if current_level > 1:
		start_game_button.visible = false
		continue_button.visible = true
		restart_button.visible = true
		if game_data.current_level == 2:
			continue_button_text.bbcode_text = "[center]continue: day two"
		elif game_data.current_level == 3:
			endless_mode_button.visible = true
			continue_button_text.bbcode_text = "[center]continue: day three"
	# game_data.boss_health = game_data.orig_boss_health


func _on_start_game_button_down():
	$BackgroundColor/Control/piece/AnimatedSprite.play("cut")
	$AudioStreamPlayer.play()


func _on_AnimatedSprite_animation_finished():
	$start_delay.start()


func _on_start_delay_timeout():
	if go_to_endless_mode:
		var _x = get_tree().change_scene("res://scenes/endless_mode/endless_mode.tscn")
		return
	if game_data.current_level == 1:
		var _x = get_tree().change_scene("res://scenes/onboarding.tscn")
	elif game_data.current_level == 2:
		var _x = get_tree().change_scene("res://scenes/day_two/day_two_intro.tscn")
	elif game_data.current_level == 3:
		var _scene = get_tree().change_scene("res://scenes/credits/credits.tscn")


func _on_credits_button_down():
	$Credits.visible = true
	$AudioStreamPlayer.play()


func _on_return_button_down():
	$Credits.visible = false
	$AudioStreamPlayer.play()


func _on_continue_button_down():
	$BackgroundColor/Control/piece/AnimatedSprite.play("cut")
	$AudioStreamPlayer.play()


func _on_restart_button_down():
	game_data.reset_progression()
	$BackgroundColor/Control/piece/AnimatedSprite.play("cut")
	$AudioStreamPlayer.play()


func _on_endless_mode_pressed():
	$BackgroundColor/Control/piece/AnimatedSprite.play("cut")
	$AudioStreamPlayer.play()
	go_to_endless_mode = true
