extends Control

#
# These ads shouldn't play if the player has bought the game
#

var close_popup = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#open_popup()


func open_popup():
	self.show()
	$AnimationPlayer.play("increase_scale")


func _on_close_pressed():
	close_popup = true
	$AnimationPlayer.play_backwards("increase_scale")


func _on_AnimationPlayer_animation_finished(anim_name):
	if close_popup:
		self.hide()
		close_popup = false
