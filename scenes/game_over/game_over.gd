extends Node2D


func _ready():
	$BackgroundColor/ScaleHelper/guide_text/AnimationPlayer.play("increase_scale")
	


func _on_AnimationPlayer_animation_finished(anim_name):
	$BackgroundColor/return/AnimationPlayer.play("increase_scale_larger")
	$hand.show()
	#$hand/AnimationPlayer.play("start_game")


func _on_return_pressed():
	var level = get_tree().change_scene("res://scenes/main_menu.tscn")
