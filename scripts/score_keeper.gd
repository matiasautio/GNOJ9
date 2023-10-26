extends Node

signal level_goal_reached
signal protesters_matched

var score = 0
var good_guy_points = 0
onready var score_text = $"../Control/score"
export var level_goal = 10000


# Called when the node enters the scene tree for the first time.
func _ready():
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"


func _on_grid_match_made(number_of_tiles, tile_group):
	var price = 70
	if tile_group == "aspen" or tile_group == "juniper":
		price = 140
	# Using the tape gives no score
	# just good guy points
	if game_data.get_node("player_status").current_tool == 2:
		good_guy_points += price * number_of_tiles
		price = 0
	score += price * number_of_tiles
	# no points for protesters
	if tile_group == "protester":
		emit_signal("protesters_matched")
		#score -= 70 * number_of_tiles # uncomment to not add score from protesters
	if score >= level_goal:
		emit_signal("level_goal_reached")
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"


func reset_score():
	score = 0
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"
