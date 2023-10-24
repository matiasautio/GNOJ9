extends Node

signal level_goal_reached
signal protesters_matched

var score = 0
onready var score_text = $"../Control/score"
export var level_goal = 100000


# Called when the node enters the scene tree for the first time.
func _ready():
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"


func _on_grid_match_made(number_of_tiles, tile_group):
	var price = 10
	score += price * number_of_tiles
	if score >= level_goal:
		emit_signal("level_goal_reached")
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"


func reset_score():
	score = 0
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"
