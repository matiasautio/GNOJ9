extends Node

signal level_goal_reached
signal protesters_matched

var score = 0
onready var score_text = $"../Control/score"
export var level_goal = 10000


# Called when the node enters the scene tree for the first time.
func _ready():
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"


func _on_grid_match_made(number_of_tiles, tile_group):
	#print(number_of_tiles)
	#print(tile_group)
	score += 70 * number_of_tiles
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"
	# no points for protesters
	if tile_group.size() > 0 and tile_group[0] == "protester":
		emit_signal("protesters_matched")
	if score >= level_goal:
		emit_signal("level_goal_reached")


func reset_score():
	score = 0
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"
