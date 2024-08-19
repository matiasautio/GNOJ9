extends Node2D

signal remove_concrete(damaged_concrete)

var warning_pieces = []
#var rocks = [] # for conveniece sake the instanced rocks get saved here too
var width = 8
var height = 10
var warning = preload("res://scenes/elements/warning_piece.tscn")

var index = 0


func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


#func _on_grid_damage_concrete(damaged_concrete):
#	if damaged_concrete.x >= concrete_pieces.size():
#		return
#	# This checks if there actually is concrete in the coordinates
#	var target_concrete = concrete_pieces[damaged_concrete.x][damaged_concrete.y]
#	if target_concrete != null:
#		print(target_concrete)
#		target_concrete.take_damage(1)
#		if target_concrete.health >= 0:
#			target_concrete.get_node("AnimatedSprite").connect("animation_finished", self, "rock_cut_finished", [target_concrete])
#			target_concrete.cut()
#			concrete_pieces[damaged_concrete.x][damaged_concrete.y] = null
#			emit_signal("remove_concrete", damaged_concrete)
#
#
#func rock_cut_finished(rock_to_delete):
#	# the bug never lets the rock go here
#	rock_to_delete.queue_free()


func _on_grid_make_warning(made_warning):
	if warning_pieces.size() == 0:
		warning_pieces = make_2d_array()
	if !warning_pieces[made_warning.x][made_warning.y] == null:
		print("Oops! This spot already has a rock. Let's skip it.")
		return
	var current
	current = warning.instance()
	add_child(current)
	current.position = Vector2(made_warning.x * 64 + 64, -made_warning.y * 64 + 800)
	warning_pieces[made_warning.x][made_warning.y] = current
