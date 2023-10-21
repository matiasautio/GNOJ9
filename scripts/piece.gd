extends Node2D

export var color : String
onready var tween
var matched = false
export var is_static = false


func _ready():
	tween = $Tween


func move(target):
	tween.interpolate_property(self, "position", position, target, .3, Tween.TRANS_ELASTIC, Tween.EASE_OUT);
	tween.start()


func dim():
	pass
	# var sprite = $Sprite
	# sprite.modulate = Color(1,1,1,0.5)


func cut():
	var sprite = $AnimatedSprite
	if sprite != null:
		if game_data.get_node("player_status").current_tool == 2:
			sprite.play("protected")
		else:
			sprite.play("cut")
