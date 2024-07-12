extends Node2D

signal remove_lock(damaged_lock)

var lock_pieces = []
var width = 8
var height = 10
var lock = preload("res://scenes/ice/ice.tscn")

#func _ready():
	#lock_pieces = make_2d_array()


func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func _on_grid_make_lock(made_lock):
	if lock_pieces.size() == 0:
		lock_pieces = make_2d_array()
	var current = lock.instance()
	add_child(current)
	current.position = Vector2(made_lock.x * 64 + 64, -made_lock.y * 64 + 800)
	lock_pieces[made_lock.x][made_lock.y] = current


func _on_grid_damage_lock(damaged_lock):
	if damaged_lock.x >= lock_pieces.size():
		return
	#print(lock_pieces[damaged_lock.x][damaged_lock.y])
	var target_lock = lock_pieces[damaged_lock.x][damaged_lock.y]
	#print(target_lock)
	if target_lock != null:
		target_lock.take_damage(1)
		if target_lock.health >= 0:
			lock_pieces[damaged_lock.x][damaged_lock.y] = null
			target_lock.queue_free()
			emit_signal("remove_lock", damaged_lock)
