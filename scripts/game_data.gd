extends Node

const is_paid_version = false

var orig_boss_health = 5
var boss_health = 5
var current_score = 0
var current_good_guys_score = 0
var total_score = 5001
var total_good_guy_score = 0

var orig_level = 0
var current_level = 1

var previous_level_name = ""
# boss, cop
var dead_character = "cop"

# endless mode
var endless_high_score = 0

# misc fun data
var protesters_killed = 0
var cops_killed = 0


func _ready():
	load_saved_progression()


# currently calculated on each outro scene closing
func calculate_score():
	print("Calculating score in gamedata")
	total_score += current_score
	total_good_guy_score += current_good_guys_score


func reset_current_score():
	print("Resetting score in gamedata")
	current_score = 0
	current_good_guys_score = 0


func reset_progression():
	boss_health = 5
	current_score = 0
	current_level = 1
	save_progression()


func save_progression():
	# save progression to disk here
	var save_dict = {
		"current_level" : current_level,
		"current_score" : current_score,
		"current_good_guys_score" : current_good_guys_score,
		"endless_high_score" : endless_high_score
	}
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var _save_nodes = get_tree().get_nodes_in_group("Persist")
	save_game.store_line(to_json(save_dict))
	print("Game saved!")
	print(save_dict)
	save_game.close()


func load_saved_progression():
	#return
	print("Loading game.")
	# load progression saved to disk here
	var save_game = File.new()
	print(save_game.file_exists("user://savegame.save"))
	if not save_game.file_exists("user://savegame.save"):
		print("No save game present!")
		return # Error! We don't have a save to load.
	
#	save_game.open("user://savegame.save", File.READ)
#	while save_game.get_position() < save_game.get_len():
#		# Get the saved dictionary from the next line in the save file
#		var node_data = parse_json(save_game.get_line())
#		current_level = node_data["current_level"]
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())
		for i in node_data.keys():
			game_data.set(i, node_data[i])
		
	save_game.close()
