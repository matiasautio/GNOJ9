extends Node


# Tools are: none, saw, tape
var current_tool = 0
enum {none, saw, tape}
var saw_node
var tape_node


func tool_selected(selected_tool):
	current_tool = selected_tool
	print("current tool is ", current_tool)
	$ToolChangeSound.play()


func no_tool_feedback():
	if current_tool == 0:
		saw_node.tool_not_selected_feedback()
	#elif current_tool == 2:
		#tape_node.tool_not_selected_feedback()
