extends Node


# flow
var box_closed = 0
var next_dialogue_requested = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DialogueBox_dialog_box_closed():
	box_closed += 1


func _on_DialogueBox_next_phrase_requested():
	next_dialogue_requested += 1
	if next_dialogue_requested == 1:
		$"../Control/Boss".visible = false
		$"../Control/Cop".visible = true
