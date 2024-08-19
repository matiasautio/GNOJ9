extends Node2D

signal remove_concrete(damaged_concrete)

var concrete_pieces = []
#var rocks = [] # for conveniece sake the instanced rocks get saved here too
var width = 8
var height = 10
var concrete = preload("res://scenes/concrete/rock.tscn")

var index = 0


func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


# currently this function is also used to make protected tiles protected as they function the same way as rocks
func _on_grid_make_concrete(made_concrete, item = null):
	if concrete_pieces.size() == 0:
		concrete_pieces = make_2d_array()
	if !concrete_pieces[made_concrete.x][made_concrete.y] == null:
		print("Oops! This spot already has a rock. Let's skip it.")
		return
	var current
	if item == null:
		current = concrete.instance()
	else:
		current = item.duplicate()
		current.get_node("AnimatedSprite").play("protected")
		#current.reparent(self)
	add_child(current)
	current.position = Vector2(made_concrete.x * 64 + 64, -made_concrete.y * 64 + 800)
	concrete_pieces[made_concrete.x][made_concrete.y] = current


func _on_grid_damage_concrete(damaged_concrete):
	if damaged_concrete.x >= concrete_pieces.size():
		return
	# This checks if there actually is concrete in the coordinates
	var target_concrete = concrete_pieces[damaged_concrete.x][damaged_concrete.y]
	if target_concrete != null:
		print(target_concrete)
		target_concrete.take_damage(1)
		if target_concrete.health >= 0:
			target_concrete.get_node("AnimatedSprite").connect("animation_finished", self, "rock_cut_finished", [target_concrete])
			target_concrete.cut()
			concrete_pieces[damaged_concrete.x][damaged_concrete.y] = null
			emit_signal("remove_concrete", damaged_concrete)


func rock_cut_finished(rock_to_delete):
	# the bug never lets the rock go here
	rock_to_delete.queue_free()
