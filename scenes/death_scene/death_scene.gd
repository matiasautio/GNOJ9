extends Node2D


var next_scene = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	var dead_character = game_data.dead_character
	if dead_character == "boss":
		$DialogueBoxHolder/DialogueBox.trigger_dialogue( "res://dialogue/death_scene/last_words_boss.json")
		$CharacterPortrait.texture = load("res://art/faces/boss_face_pain.png")
		next_scene = "res://scenes/outro_boss_dead.tscn"
		
	elif dead_character == "cop":
		$DialogueBoxHolder/DialogueBox.trigger_dialogue( "res://dialogue/death_scene/last_words_cop.json")
		$CharacterPortrait.texture = load("res://art/faces/cop_pain.png")
		next_scene = "res://scenes/day_two/day_two_cop_died.tscn"


func _on_DialogueBox_dialog_box_closed():
	var _x = get_tree().change_scene(next_scene)
