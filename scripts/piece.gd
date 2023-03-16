extends Node2D

@export var color : String
@onready var tween
var matched = false

func move(target):
	tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target, 0.3)


func dim():
	var sprite = $Sprite2D
	sprite.modulate = Color(1,1,1,0.5)
