extends Node2D


export (int) var health = 1

func _ready():
	pass
	

func take_damage(damage):
	health -= damage
	# can add damage effect here
	
