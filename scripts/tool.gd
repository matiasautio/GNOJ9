extends AnimatedSprite


onready var tool_sprite = self
var is_selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func toggle_selection():
	is_selected = !is_selected
	if is_selected:
		tool_sprite.play("selected")
		$"../../grid".can_play = true
	else:
		tool_sprite.play("default")


func _on_tool_button_button_down():
	toggle_selection()
