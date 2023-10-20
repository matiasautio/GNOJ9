extends Node

# Place this script into an object thats higher in the hierarchy than the grid for it to run first


onready var grid = $"../grid"
var screen_size


func _ready():
	screen_size = get_viewport().get_visible_rect().size
	#print(screen_size.x)
	grid.x_start = (screen_size.x - (grid.width - 1) * 64) / 2
	print(grid.x_start)
	grid.y_start = (screen_size.y - grid.height * 64) / 2 + (grid.height - 1) * 64
	print(grid.y_start)

