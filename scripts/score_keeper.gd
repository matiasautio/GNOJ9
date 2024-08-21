extends Node

signal level_goal_reached
signal protesters_matched
signal cannot_score

export var can_score = true
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
	#if xr_score_text != null:
		#xr_score_text.bbcode_text = "[center]" + String(good_guy_points) + "[/center]"
	set_score_color()


func _on_grid_match_made(number_of_tiles, tile_group):
	#print(number_of_tiles, tile_group)
	var current_tool = game_data.get_node("player_status").current_tool
	if !can_score:
		emit_signal("cannot_score")
		return
	var price = 70
	if tile_group == "aspen" or tile_group == "juniper":
		price = 140
	if tile_group == "rock":
		price = 100
		# no money for protecting rocks as nothing happens
		if current_tool == 2:
			price = 0
	if current_tool == 2:
		# double money for not killing people
		if tile_group == "protester" or tile_group == "cop":
			price = 140
		good_guy_points += price * number_of_tiles
		score -= price * number_of_tiles
		price = 0
	score += price * number_of_tiles
	# no points for protesters
	if tile_group == "protester":
		emit_signal("protesters_matched")
		#score -= 70 * number_of_tiles # uncomment to not add score from protesters
	# To pass a level's score threshold, both point types are used
	# score threshold without other conditions like a timer is boring, so not used atm
	var total_score = score# + good_guy_points
	if total_score >= level_goal:
		emit_signal("level_goal_reached")
	score_text.bbcode_text = "[center]" + String(abs(score)) + "[/center]"
	set_score_color()
	#if xr_score_text != null:
		#xr_score_text.bbcode_text = "[center]" + String(good_guy_points) + "[/center]"


func set_score_color():
	if score < 0:
		score_text.self_modulate = Color(0.4, 0.59, 0.01)
	else:
		score_text.self_modulate = Color(1, 1, 1)


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
