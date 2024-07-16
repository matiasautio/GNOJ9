extends Node2D


signal match_made(number_of_tiles, tile_group)
signal pieces_generated()

# General gameplay variables
export var can_play = false
# matches can happen on their own too when pieces collapse
# this helps to check if a match was made from player's input
var player_swapped = false
signal swap_succesful

# State machine
enum {wait, move}
var state

# Grid variables
export var width : int
export var height : int
export var x_start : int
export var y_start : int
export var offset : int
export var y_offset : int

# Obstacle stuff
export (Array, Vector2) var empty_spaces
export (Array, Vector2) var ice_spaces
export var random_ice = false
export (Array, Vector2) var lock_spaces
export var random_locks = false
export (Array, Vector2) var concrete_spaces
export var random_concrete = false

export (Array, Vector2) var protected_tiles
export (Array, Vector2) var just_protected_tiles

# Obstacle signals
signal damage_ice(damaged_ice)
signal make_ice(made_ice)
signal damage_lock(damaged_lock)
signal make_lock(made_lock)
signal damage_concrete(damaged_concrete)
signal make_concrete(made_concrete)

# Tape tool stuff
signal deadlocked

# Gameplay variables
export var use_refill : bool = true
# If the current tool is tape, this is set true
var is_protecting = false

# Piece array
export (Array, PackedScene) var possible_pieces = [
	preload("res://scenes/pieces/birch_piece.tscn"),
	preload("res://scenes/pieces/fir_piece.tscn"),
	preload("res://scenes/pieces/pine_piece.tscn"),
	preload("res://scenes/pieces/protester_piece.tscn"),
	preload("res://scenes/pieces/juniper_piece.tscn")
]

# Current pieces in the scene
var all_pieces = []
var clone_array = []

# Swap back variables
var piece_one = null
var piece_two = null
var last_place = Vector2(0,0)
var last_direction = Vector2(0,0)
var move_checked = false

# Touch variable
var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false

# Pausing and resetting variables
# no variables for this currently

func _ready():
	var _x = $"../destroy_timer".connect("timeout", self, "_on_destroy_timer_timeout")
	_x = $"../collapse_timer".connect("timeout", self, "_on_collapse_timer_timeout")
	_x = $"../refill_timer".connect("timeout", self, "_on_refill_timer_timeout")
	_x = connect("match_made", $"../score_keeper", "_on_grid_match_made")
	randomize()
	state = move
	#print(empty_spaces)
	all_pieces = make_2d_array()
	clone_array = make_2d_array()
	if ice_spaces.size() > 0 or random_ice:
		spawn_ice()
	if lock_spaces.size() > 0 or random_locks:
		spawn_locks()
	if concrete_spaces.size() > 0 or random_concrete:
		spawn_concrete()
	if possible_pieces.size() > 0:
		spawn_pieces()
	# Connect score keeper
	#connect("match_made", $"../score_keeper", "_on_grid_match_made")


func restricted_fill(place):
	# Check the empty pieces
	if is_in_array(empty_spaces, place):
		return true
	if is_in_array(concrete_spaces, place):
		return true
	else:
		return false


func restricted_move(place):
	if is_in_array(lock_spaces, place):
		return true
	if is_in_array(concrete_spaces, place):
		return true
	else:
		return false


func is_in_array(array, item):
	if item in array:
		return true
	else:
		return false


func remove_from_array(array, item):
	for i in range(array.size() -1, -1, -1):
		if array[i] == item:
			array.remove(i)
	return array


func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func spawn_pieces():
	for i in width:
		for j in height:
			if !restricted_fill(Vector2(i,j)):
				# pick a random number and store it
				var rand = floor(rand_range(0, possible_pieces.size()))
				var piece = possible_pieces[rand].instance()
				var loops = 0
				while(match_at(i, j, piece.color) and loops < 100):
					rand = floor(rand_range(0, possible_pieces.size()))
					loops += 1
					piece = possible_pieces[rand].instance()
				# instantiate piece from array
				add_child(piece)
				piece.position = grid_to_pixel(i, j)
				all_pieces[i][j] = piece
	emit_signal("pieces_generated")


func spawn_ice():
	if random_ice:
		for _i in range(4):
			ice_spaces.append(Vector2(int(rand_range(0,7)),int(rand_range(0, 9))))
	#print(ice_spaces)
	for i in ice_spaces.size():
		emit_signal("make_ice", ice_spaces[i])


func spawn_locks():
	if random_locks:
		for _i in range(4):
			lock_spaces.append(Vector2(int(rand_range(0,7)),int(rand_range(0, 9))))
	for i in lock_spaces.size():
		emit_signal("make_lock", lock_spaces[i])


func spawn_concrete():
	if random_concrete:
		for _i in range(4):
			concrete_spaces.append(Vector2(int(rand_range(0,7)),int(rand_range(0, 9))))
	for i in concrete_spaces.size():
		emit_signal("make_concrete", concrete_spaces[i])


#  Is the balancing managed here? By determining 
func match_at(column, row, color):
	if column > 1:
		if all_pieces[column-1][row] != null and all_pieces[column-2][row] != null:
			if all_pieces[column-1][row].color == color && all_pieces[column-2][row].color == color:
				return true
	if row > 1:
		if all_pieces[column][row-1] != null and all_pieces[column][row-2] != null:
			if all_pieces[column][row-1].color == color && all_pieces[column][row-2].color == color:
				return true


func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)


func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y)


func is_in_grid(grid_position):
	if grid_position.x >= 0 and grid_position.x < width:
		if grid_position.y >= 0 and grid_position.y < height:
			#controlling = true
			return true
	#controlling = false
	return false


func touch_input():
	if can_play:
		if Input.is_action_just_pressed("ui_touch"):
			var mouse = get_global_mouse_position()
			mouse = pixel_to_grid(mouse.x, mouse.y)
			if is_in_grid(mouse):
				first_touch = mouse
				controlling = true
		if Input.is_action_just_released("ui_touch"):
			var mouse = get_global_mouse_position()
			mouse = pixel_to_grid(mouse.x, mouse.y)
			if is_in_grid(mouse) and controlling:
				final_touch = mouse
				player_swapped = true
				touch_difference(first_touch, final_touch)
			controlling = false


func swap_pieces(column, row, direction):
	#print("Swapping pieces")
	# Let's check which tool the player is using
	if game_data.get_node("player_status").current_tool == 2:
		is_protecting = true
	else:
		is_protecting = false
	#
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	# if !first_piece.is_static and !other_piece.is_static and first_piece != null and other_piece != null:
	if first_piece != null and other_piece != null:
		if !restricted_move(Vector2(column, row)) and !restricted_move(Vector2(column, row) + direction):
			store_info(first_piece, other_piece, Vector2(column, row), direction)
			state = wait
			all_pieces[column][row] = other_piece
			all_pieces[column + direction.x][row + direction.y] = first_piece
			first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
			other_piece.move(grid_to_pixel(column, row))
			$Swap.play()
			if !move_checked:
				find_matches()


func store_info(first_piece, other_piece, place, direction):
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction


func swap_back():
	# Move the previously moved pieces back to the previous place
	#print(piece_one)
	#print(piece_two)
	if piece_one != null and piece_two != null:
		#if !piece_one.protected and !piece_two.protected:
		swap_pieces(last_place.x, last_place.y, last_direction)
	state = move
	move_checked = false
	#piece_one = null
	#piece_two = null


func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0))
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1, 0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))


func _process(_delta):
	if state == move:
		touch_input()


func find_matches(query = false, array = all_pieces):
	#print("Finding matches.")
	for i in width:
		for j in height:
			if array[i][j] != null:
				var current_color = array[i][j].color
				if i > 0 && i < width - 1:
					if !is_piece_null(i - 1, j) and !is_piece_null(i + 1, j):
						if array[i - 1][j].color == current_color and array[i + 1][j].color == current_color:
							if query:
								return true
							match_and_dim(array[i - 1][j], Vector2(i - 1,j))
							match_and_dim(array[i][j], Vector2(i,j))
							match_and_dim(array[i + 1][j], Vector2(i + 1,j))
						if is_protecting:
							$Protect.play_audio()
						else:
							$Destroy.play_audio()
				if j > 0 && j < height - 1:
					if array[i][j - 1] != null && array[i][j + 1] != null:
						if array[i][j - 1].color == current_color and array[i][j + 1].color == current_color:
							if query:
								return true
							match_and_dim(array[i][j - 1], Vector2(i,j -1))
							match_and_dim(array[i][j], Vector2(i,j))
							match_and_dim(array[i][j + 1], Vector2(i,j + 1))
						if is_protecting:
							$Protect.play_audio()
						else:
							$Destroy.play_audio()
	if query:
		return false
	$"../destroy_timer".start()


func is_piece_null(column, row):
	if all_pieces[column][row] == null:
		return true
	else:
		return false


func match_and_dim(item, pos):
	if is_protecting:
		#print("should protect")
		#just_protected_tiles.append(pos)
		concrete_spaces.append(pos)
		emit_signal("make_concrete", pos, item)
		#empty_spaces.append(pos)
		#item.protected = true
		#item.hide()
		item.cut()
		item.matched = true
		item.dim()
	else:
		item.cut()
		item.matched = true
		item.dim()


func destroy_matched():
	#print("Destroying matched tiles.")
	var number_of_tiles = 0 # Used to emit the score
	var tile_group = ""
	var was_matched = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					#print("Tile checked is ", Vector2(i, j), " list is currently ", just_protected_tiles)
					if !is_protecting:
						damage_special(i, j)
					was_matched = true
					tile_group = all_pieces[i][j].color
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
					number_of_tiles += 1
				
	move_checked = true
	if was_matched:
		#print("Tiles were matched!")
		#print(number_of_tiles, " tiles were matched")'
		# Tiles per match per group could be added to an array and the points given re that
		emit_signal("match_made", number_of_tiles, tile_group)
		$"../collapse_timer".start()
		if player_swapped:
			emit_signal("swap_succesful")
	else:
		#if !was_protected:
		#print("Tiles were not matched!")
		$FailSound.play()
		swap_back()
		#else:
			#if player_swapped:
			#	emit_signal("swap_succesful")
			#state = move
			#move_checked = false
			#print("Tile was protected!")
	# making sure this is always reverted to false
	player_swapped = false


func check_concrete(column, row):
	# Check cardinal directions for a concrete to remove
	if column < width -1:
		emit_signal("damage_concrete", Vector2(column + 1, row))
	if column > 0:
		emit_signal("damage_concrete", Vector2(column - 1, row))
	if row < height - 1:
		emit_signal("damage_concrete", Vector2(column, row + 1))
	if row > 0:
		emit_signal("damage_concrete", Vector2(column, row - 1))


func damage_special(column, row):
	emit_signal("damage_ice", Vector2(column,row))
	emit_signal("damage_lock", Vector2(column,row))
	check_concrete(column, row)


func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null and !restricted_fill(Vector2(i,j)):
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	$"../refill_timer".start()


# after pieces get removed, more are spawned in
func refill_columns():
	for i in width:
		for j in height:
			# if the spot is empty we'll spawn a new piece
			if all_pieces[i][j] == null and !restricted_fill(Vector2(i,j)):
				var rand = floor(rand_range(0, possible_pieces.size()))
				var piece = possible_pieces[rand].instance()
				var loops = 0
				while(match_at(i, j, piece.color) and loops < 100):
					rand = floor(rand_range(0, possible_pieces.size()))
					loops += 1
					piece = possible_pieces[rand].instance()
				add_child(piece)
				piece.position = grid_to_pixel(i, j - y_offset)
				piece.move(grid_to_pixel(i, j))			
				all_pieces[i][j] = piece
	after_refill()


func after_refill():
	#print("After refilling.")
	if !is_protecting:
		$TreesDropping.play_audio()
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].color) and !all_pieces[i][j].matched and !all_pieces[i][j].protected:
					#print("Found matches after refill")
					find_matches()
					$"../destroy_timer".start()
					return
				#else:
					#all_pieces[i][j].matched = false
	state = move
	move_checked = false
	if is_deadlocked():
		emit_signal("deadlocked")
		print("deadlocked")
	#for tile in just_protected_tiles:
		#tile.matched = false
	just_protected_tiles.clear()
	#print("Grid is done moving")
	# clear just matched


func is_deadlocked():
	# Create a copy of the all_pieces array
	clone_array = copy_array(all_pieces)
	for i in width:
		for j in height:
			#switch and check right
			if switch_and_check(Vector2(i,j), Vector2(1, 0), clone_array):
				return false
			#switch and check up
			if switch_and_check(Vector2(i,j), Vector2(0, 1), clone_array):
				return false
	return true


func switch_and_check(place, direction, array):
	switch_pieces(place, direction, array)
	if find_matches(true, array):
		switch_pieces(place, direction, array)
		return true
	else:
		switch_pieces(place, direction, array)
		#print("No match found")
		return false


func switch_pieces(place, direction, array):
	if is_in_grid(place) and !restricted_fill(place):
		if is_in_grid(place + direction) and !restricted_fill(place + direction):
			# First, hold the piece to swap with
			var holder = array[place.x + direction.x][place.y + direction.y]
			# Then set the swap spot as the original piece
			array[place.x + direction.x][place.y + direction.y] = array[place.x][place.y]
			# Then set the original spot as the other piece
			array[place.x][place.y] = holder


func copy_array(array_to_copy):
	var new_array = make_2d_array()
	for i in width:
		for j in height:
			new_array[i][j] = array_to_copy[i][j]
	return new_array


func _on_destroy_timer_timeout():
	destroy_matched()

	
func _on_sound_timer_timeout():
	if !is_protecting:
		$TreesDropping.play_audio()


func _on_collapse_timer_timeout():
	if !is_protecting:
		$TreesDropping.play_audio()
	collapse_columns()


func _on_refill_timer_timeout():
	if !is_protecting:
		$TreesDropping.play_audio()
	if use_refill:
		refill_columns()
	else:
		after_refill()


func pause():
	print("pausing grid")
	$"../destroy_timer".stop()
	$"../collapse_timer".stop()
	$"../refill_timer".stop()


func reset():
	print("resetting grid")
	#empty_spaces.clear()
	destroy_matched()
	concrete_spaces.clear()
	for child in self.get_children():
		if !child.is_class("AudioStreamPlayer") and !child.is_class("Timer"):
			self.remove_child(child)
			child.queue_free()
	state = move
	# these two might be reduntant
	#piece_one = null
	#piece_two = null
	#just_protected_tiles.clear()
	spawn_pieces()


func _on_lock_holder_remove_lock(damaged_lock):
	lock_spaces = remove_from_array(lock_spaces, damaged_lock)


func _on_concrete_holder_remove_concrete(damaged_concrete):
	concrete_spaces = remove_from_array(concrete_spaces, damaged_concrete)
	#empty_spaces = remove_from_array(empty_spaces, damaged_concrete)
