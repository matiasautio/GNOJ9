extends Node2D

func _on_DialogueBox_dialog_box_closed():
	$FadeOut/AnimationPlayer.play("fade_out")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		var _x = get_tree().change_scene("res://scenes/main_menu.tscn")
