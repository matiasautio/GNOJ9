extends Node2D


onready var game_data = get_node("/root/game_data")

# Reset game data
func _ready():
	game_data.boss_health = game_data.orig_boss_health


func _on_start_game_button_down():
	$BackgroundColor/Control/piece/AnimatedSprite.play("cut")
	$AudioStreamPlayer.play()


func _on_AnimatedSprite_animation_finished():
	$start_delay.start()


func _on_start_delay_timeout():
	var _x = get_tree().change_scene("res://scenes/intro.tscn")
