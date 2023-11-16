extends Node2D

# alempi laku pos = 103,369
# ylmepi laku pos = 194,261.5

func _on_start_game_pressed():
	print("start")
	$laku_curtains.get_node("curtains_animation").connect("animation_finished", self, "_on_curtains_animation_animation_finished")
	$laku_curtains.get_node("curtains_animation").play("curtains_close")


func _on_start_delay_timeout():
	$bg/logo_animation.play("laku_smashing")


func _on_curtains_animation_animation_finished(anim_name):
	get_tree().change_scene("res://laku_smash/laku_smash.tscn")


func _on_logo_animation_animation_finished(anim_name):
	$bg/play/visible_delay.start()


func _on_visible_delay_timeout():
	$bg/play.visible = true


func _on_play_pressed():
	_on_start_game_pressed()
