extends Node


enum {none, saw, hand}
var current_tool


# Called when the node enters the scene tree for the first time.
func _ready():
	current_tool = none


func _on_tool_button_button_down():
	if current_tool != saw:
		current_tool = saw
	else:
		current_tool = none
	# print("current tool is ", current_tool)
	$ToolChangeSound.play()
