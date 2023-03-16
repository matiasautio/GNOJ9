extends Node2D

# Grid variables
@export var width : int
@export var height : int
@export var x_start : int
@export var y_start : int
@export var offset : int

# Piece array
@export var possible_pieces = [
	preload("res://scenes/yellow_piece.tscn"),
	preload("res://scenes/green_piece.tscn"),
	preload("res://scenes/orange_piece.tscn"),
	preload("res://scenes/pink_piece.tscn"),
	preload("res://scenes/blue_piece.tscn")
]

# Current pieces in the scene
var all_pieces = []

# Touch variable
var first_touch = Vector2(0,0)
var final_touch = Vector2(0,0)
var controlling = false


func _ready():
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()


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
			# pick a random numer and store it
			var rand = floor(randf_range(0, possible_pieces.size()))
			var piece = possible_pieces[rand].instantiate()
			var loops = 0
			while(match_at(i, j, piece.color) and loops < 100):
				rand = floor(randf_range(0, possible_pieces.size()))
				loops += 1
				piece = possible_pieces[rand].instantiate()
			# instantiate piece from array
			add_child(piece)
			piece.position = grid_to_pixel(i, j)
			all_pieces[i][j] = piece


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
			touch_difference(first_touch, final_touch)
		controlling = false


func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null and other_piece != null:
		all_pieces[column][row] = other_piece
		all_pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(column, row))
		find_matches()


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
	touch_input()


func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				if i > 0 && i < width - 1:
					if all_pieces[i - 1][j] !=null && all_pieces[i + 1][j] != null:
						if all_pieces[i - 1][j].color == current_color and all_pieces[i + 1][j].color == current_color:
							all_pieces[i - 1][j].matched = true
							all_pieces[i - 1][j].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i + 1][j].matched = true
							all_pieces[i + 1][j].dim()
				if j > 0 && j < height - 1:
					if all_pieces[i][j - 1] !=null && all_pieces[i][j + 1] != null:
						if all_pieces[i][j - 1].color == current_color and all_pieces[i][j + 1].color == current_color:
							all_pieces[i][j - 1].matched = true
							all_pieces[i][j - 1].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i][j + 1].matched = true
							all_pieces[i][j + 1].dim()
	$"../destroy_timer".start()


func destroy_matched():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
			
func _on_destroy_timer_timeout():
	destroy_matched()
