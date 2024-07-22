extends Node

signal level_goal_reached
signal protesters_matched

var score = 0
var good_guy_points = 0
onready var score_text = $"../Control/score"
var xr_score_text = null
export var level_goal = 10000

# Current highest scores
var current_highscore = 0
var current_good_guy_highscore = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"
	xr_score_text = get_node_or_null("../Control/xr_score")
	if xr_score_text != null:
		xr_score_text.bbcode_text = "[center]" + String(good_guy_points) + "[/center]"


func _on_grid_match_made(number_of_tiles, tile_group):
	#print(number_of_tiles, tile_group)
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
	# To pass a level's score threshold, both point types are used
	var total_score = score + good_guy_points
	if total_score >= level_goal:
		emit_signal("level_goal_reached")
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"
	if xr_score_text != null:
		xr_score_text.bbcode_text = "[center]" + String(good_guy_points) + "[/center]"


func reset_score():
	print("resetting score")
	# Add highscores
	if score > current_highscore:
		current_highscore = score
	if good_guy_points > current_good_guy_highscore:
		current_good_guy_highscore = good_guy_points
	score = 0
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"
	good_guy_points = 0
	if xr_score_text != null:
		xr_score_text.bbcode_text = "[center]" + String(good_guy_points) + "[/center]"
	

func get_highscores():
	print("getting score")
	if score > current_highscore:
		current_highscore = score
	if good_guy_points > current_good_guy_highscore:
		current_good_guy_highscore = good_guy_points
	var highscores = Vector2(current_highscore, current_good_guy_highscore)
	return highscores
