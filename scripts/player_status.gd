extends Node


# Tools are: none, saw, tape
var current_tool = 0
enum {none, saw, tape}


func tool_selected(selected_tool):
	current_tool = selected_tool
	print("current tool is ", current_tool)
	$ToolChangeSound.play()
