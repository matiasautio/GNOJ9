extends Node


enum {none, saw, tape}
var current_tool


# Called when the node enters the scene tree for the first time.
func _ready():
	current_tool = none


func tool_selected(selected_tool):
	current_tool = selected_tool
	print("current tool is ", current_tool)
	$ToolChangeSound.play()
