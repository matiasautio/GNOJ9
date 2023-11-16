extends Node


var hi_score = 0

func _ready():
	load_saved_progression()

func save_progression():
	var save_dict = {
		"hi_score" : hi_score
	}
	var save_game = File.new()
	save_game.open("user://lakusmash.save", File.WRITE)
	#var save_nodes = get_tree().get_nodes_in_group("Persist")
	save_game.store_line(to_json(save_dict))
	print("Game saved!")
	save_game.close()


func load_saved_progression():
	var save_game = File.new()
	print(save_game.file_exists("user://lakusmash.save"))
	if not save_game.file_exists("user://lakusmash.save"):
		print("No save game present!")
		return # Error! We don't have a save to load.
	
	save_game.open("user://lakusmash.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())
		hi_score = node_data["hi_score"]
		
	save_game.close()
