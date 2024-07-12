extends Node2D

signal remove_concrete(damaged_concrete)

var concrete_pieces = []
var width = 8
var height = 10
var concrete = preload("res://scenes/ice/ice.tscn")

#func _ready():
	#concrete_pieces = make_2d_array()


func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func _on_grid_make_concrete(made_concrete, item = null):
	if concrete_pieces.size() == 0:
		concrete_pieces = make_2d_array()
	var current
	if item == null:
		current = concrete.instance()
	else:
		current = item.duplicate()
		#current.reparent(self)
	add_child(current)
	current.get_node("AnimatedSprite").play("protected")
	current.position = Vector2(made_concrete.x * 64 + 64, -made_concrete.y * 64 + 800)
	concrete_pieces[made_concrete.x][made_concrete.y] = current


func _on_grid_damage_concrete(damaged_concrete):
	if damaged_concrete.x >= concrete_pieces.size():
		return
	#print(concrete_pieces[damaged_concrete.x][damaged_concrete.y])
	var target_concrete = concrete_pieces[damaged_concrete.x][damaged_concrete.y]
	#print(target_concrete)
	if target_concrete != null:
		target_concrete.take_damage(1)
		if target_concrete.health >= 0:
			target_concrete.queue_free()
			concrete_pieces[damaged_concrete.x][damaged_concrete.y] = null
			emit_signal("remove_concrete", damaged_concrete)
