extends Node2D

var ice_pieces = []
var width = 8
var height = 10
var ice = preload("res://scenes/ice/ice.tscn")

#func _ready():
	#ice_pieces = make_2d_array()


func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array



func _on_grid_make_ice(made_ice):
	if ice_pieces.size() == 0:
		ice_pieces = make_2d_array()
	var current = ice.instance()
	add_child(current)
	current.position = Vector2(made_ice.x * 64 + 64, -made_ice.y * 64 + 800)
	ice_pieces[made_ice.x][made_ice.y] = current


func _on_grid_damage_ice(damaged_ice):
	if damaged_ice.x >= ice_pieces.size():
		return
	#print("ice damaged")
	#print(ice_pieces[damaged_ice.x][damaged_ice.y])
	var target_ice = ice_pieces[damaged_ice.x][damaged_ice.y]
	#print(target_ice)
	if target_ice != null:
		target_ice.take_damage(1)
		if target_ice.health >= 0:
			ice_pieces[damaged_ice.x][damaged_ice.y] = null
			target_ice.queue_free()
