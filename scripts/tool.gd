extends AnimatedSprite


var can_swap = true
onready var tool_sprite = self
onready var player_status = get_node("/root/game_data/player_status")
var is_selected = false
export var tool_i_am = 1


func _ready():
	$"../../grid".connect("swapping_pieces", self, "swapping_pieces")
	$"../../grid".connect("grid_stopped", self, "grid_stopped")
	if tool_i_am == 1:
		game_data.get_node("player_status").saw_node = self
	elif tool_i_am == 2:
		game_data.get_node("player_status").tape_node = self


func swapping_pieces():
	if can_swap:
		can_swap = false


func grid_stopped():
	if !can_swap:
		can_swap = true


func toggle_selection():
	is_selected = !is_selected
	if is_selected:
		select()
	else:
		$"../../grid".can_play = false
		player_status.tool_selected(0)
		deselect()


func select():
	player_status.tool_selected(tool_i_am)
	tool_sprite.play("selected")
	$"../../grid".can_play = true
	for member in get_tree().get_nodes_in_group("tools"):
		if member != self:
			member.deselect()


func deselect():
	# $"../../grid".can_play = false
	tool_sprite.play("default")
	is_selected = false


func _on_tool_button_button_down():
	if can_swap:
		toggle_selection()


func tool_not_selected_feedback():
	if !$"../DialogueBoxHolder/DialogueBox".visible:
		$AnimationPlayer.play("feedback")
		$tool_not_selected.play()
