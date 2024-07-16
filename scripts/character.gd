extends AnimatedSprite

class_name Character

signal dead


var is_present = true
# When the character stays onscreen and is not goign away anymore
var can_talk_to

var current_dialogue = null
var current_level

onready var player_status = get_node("/root/game_data/player_status")


func _ready():
	can_talk_to = false


func clicked():
	pass


func toggle_status():
	print("Toggling character")
	# if boss is interactable we don't want him to go away
	#print("can talk to is ", can_talk_to)
	if can_talk_to or current_dialogue != null:
		print("The character is supposed to stay on screen. Not toggling him away!")
		return
	if is_present:
		is_present = false
		self.play("away")
		print("Playing character goes away.")
	else:
		is_present = true
		self.play("default")
		print("Playing character appears.")
