extends Node


var orig_boss_health = 5
var boss_health = 5
var current_score = 0

var orig_level = 0
var current_level = 1

# misc fun data
var protesters_killed


func _ready():
	load_saved_progression()


func reset_progression():
	boss_health = 5
	current_score = 0
	current_level = 1
	save_progression()

func save_progression():
	# save progression to disk here
	var save_dict = {
		"current_level" : current_level
	}
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	save_game.store_line(to_json(save_dict))
	print("Game saved!")
	save_game.close()


func load_saved_progression():
	# load progression saved to disk here
	var save_game = File.new()
	print(save_game.file_exists("user://savegame.save"))
	if not save_game.file_exists("user://savegame.save"):
		print("No save game present!")
		return # Error! We don't have a save to load.
	
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())
		current_level = node_data["current_level"]
		
	save_game.close()
