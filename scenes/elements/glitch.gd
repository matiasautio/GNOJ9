extends Sprite

signal glitch_removed

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_GlitchButton_pressed():
	if game_data.get_node("player_status").current_tool == 1:
		emit_signal("glitch_removed")
		hide()


func _on_score_keeper_cannot_score():
	$AnimationPlayer.play("glitch")
