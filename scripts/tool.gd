extends AnimatedSprite


onready var tool_sprite = self
onready var player_status = get_node("/root/game_data/player_status")
var is_selected = false
export var tool_i_am = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
	toggle_selection()
