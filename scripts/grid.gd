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
export (Array, Vector2) var protected_tiles
export (Array, Vector2) var just_protected_tiles

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
	all_pieces = make_2d_array()
	if possible_pieces.size() > 0:
		spawn_pieces()


func restricted_movement(place):
	# Check the empty pieces
	for i in empty_spaces.size():
		if empty_spaces[i] == place:
			return true
	return false


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
			if !restricted_movement(Vector2(i,j)):
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
	print("Swapping pieces")
	# Let's check which tool the player is using
	if game_data.get_node("player_status").current_tool == 2:
		is_protecting = true
	else:
		is_protecting = false
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	# if !first_piece.is_static and !other_piece.is_static and first_piece != null and other_piece != null:
	if first_piece != null and other_piece != null:
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
	print(piece_one)
	print(piece_two)
	if piece_one != null and piece_two != null:
		#if !piece_one.protected and !piece_two.protected:
		swap_pieces(last_place.x, last_place.y, last_direction)
	state = move
	move_checked = false
	piece_one = null
	piece_two = null


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


func find_matches():
	print("Finding matches.")
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				var protected = all_pieces[i][j].protected
				#var care_about_protection = true
				if i > 0 && i < width - 1:
					if all_pieces[i - 1][j] != null && all_pieces[i + 1][j] != null:
#						if all_pieces[i - 1][j].protected != protected and all_pieces[i + 1][j].protected != protected:
#							#print("asd")
#							care_about_protection = false
						if all_pieces[i - 1][j].color == current_color and all_pieces[i + 1][j].color == current_color:
							if !all_pieces[i - 1][j].protected:
								all_pieces[i - 1][j].matched = true
								all_pieces[i - 1][j].dim()
								all_pieces[i - 1][j].cut()
							if !all_pieces[i][j].protected:
								all_pieces[i][j].matched = true
								all_pieces[i][j].dim()
								all_pieces[i][j].cut()
							if !all_pieces[i + 1][j].protected:
								all_pieces[i + 1][j].matched = true
								all_pieces[i + 1][j].dim()
								all_pieces[i + 1][j].cut()
							
							print(all_pieces[i][j])
						if is_protecting:
							$Protect.play_audio()
						else:
							$Destroy.play_audio()
				if j > 0 && j < height - 1:
					if all_pieces[i][j - 1] != null && all_pieces[i][j + 1] != null:
						if all_pieces[i][j - 1].color == current_color and all_pieces[i][j + 1].color == current_color:
							if !all_pieces[i][j - 1].protected:
								all_pieces[i][j - 1].matched = true
								all_pieces[i][j - 1].dim()
								all_pieces[i][j - 1].cut()
							if !all_pieces[i][j].protected:
								all_pieces[i][j].matched = true
								all_pieces[i][j].dim()
								all_pieces[i][j].cut()
							if !all_pieces[i][j + 1].protected:
								all_pieces[i][j + 1].matched = true
								all_pieces[i][j + 1].dim()
								all_pieces[i][j + 1].cut()
						if is_protecting:
							$Protect.play_audio()
						else:
							$Destroy.play_audio()
	$"../destroy_timer".start()


func destroy_matched():
	print("Destroying matched tiles.")
	var number_of_tiles = 0 # Used to emit the score
	var tile_group
	var was_matched = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					if !all_pieces[i][j] in just_protected_tiles:
						#pass
						was_matched = true
						tile_group = all_pieces[i][j].color#get_groups()
						if game_data.get_node("player_status").current_tool == 2:
							#pass
							#all_pieces[i][j].queue_free()
							#empty_spaces.append(Vector2(i,j))
							#protected_tiles.append(Vector2(i,j))
							just_protected_tiles.append(all_pieces[i][j])
							#all_pieces[i][j].matched = false
						else:
							# remove if unnecessary
							if piece_one == all_pieces[i][j]:
								piece_one = null
							if piece_two == all_pieces[i][j]:
								piece_two = null
							all_pieces[i][j].queue_free()
							# This removes the matched piece from the board
							all_pieces[i][j] = null
						print(tile_group)
						number_of_tiles += 1
				
	move_checked = true
	if was_matched:
		print("Tiles were matched!")
		print(number_of_tiles, " tiles were matched")
		emit_signal("match_made", number_of_tiles, tile_group)
		$"../collapse_timer".start()
		if player_swapped:
			emit_signal("swap_succesful")
	else:
		print("Tiles were not matched!")
		$FailSound.play()
		swap_back()
	# making sure this is always reverted to false
	player_swapped = false


func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null and !restricted_movement(Vector2(i,j)):
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
			if all_pieces[i][j] == null and !restricted_movement(Vector2(i,j)):
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
	print("After refilling.")
	if !is_protecting:
		$TreesDropping.play_audio()
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].color) and !all_pieces[i][j].matched and !all_pieces[i][j].protected:
					print("Found matches after refill")
					find_matches()
					$"../destroy_timer".start()
					return
				#else:
					#all_pieces[i][j].matched = false
	state = move
	move_checked = false
	for tile in just_protected_tiles:
		tile.matched = false
	just_protected_tiles.clear()
	# clear just matched


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
	empty_spaces.clear()
	destroy_matched()
	for child in self.get_children():
		if !child.is_class("AudioStreamPlayer") and !child.is_class("Timer"):
			self.remove_child(child)
			child.queue_free()
	state = move
	# these two might be reduntant
	piece_one = null
	piece_two = null
	just_protected_tiles.clear()
	spawn_pieces()

