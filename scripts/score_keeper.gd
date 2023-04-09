extends Node

signal level_goal_reached

var score = 0
onready var score_text = $"../Control/score"
export var level_goal = 10000


# Called when the node enters the scene tree for the first time.
func _ready():
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_grid_match_made(number_of_tiles):
	print(number_of_tiles)
	score += 70 * number_of_tiles
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"
	if score >= level_goal:
		emit_signal("level_goal_reached")


func reset_score():
	score = 0
	score_text.bbcode_text = "[center]" + String(score) + "[/center]"
