extends Node2D

export var color : String
onready var tween
var matched = false


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
		sprite.play("cut")
