extends Node2D


onready var game_data = get_node("/root/game_data")
onready var background = $BackgroundColor
var orig_color
var dream_color = "023548"

var dream_sequence_index = 0
onready var dream_vision = $dream_vision

var scene_sequence_index = 0

onready var narrator = $NarratorFace
onready var protester = $Protester
onready var visitor = $Visitor

# 1, 2, 3
export var day = 1
export var protester_sounds = "boss"
export var visitor_sounds = "boss"
export (String, MULTILINE) var prostester_dialogue: String = "res://dialogue/protester_visit.json"
export (String, MULTILINE) var visitor_dialogue : String = "res://dialogue/day_two/it_visit.json"
export (String, MULTILINE) var next_scene : String = "res://scenes/day_two/day_two_intro.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	$DialogueBoxHolder/DialogueBox/CharacterVoice.set_sounds("dream")
	orig_color = background.color
	background.color = dream_color


func _on_DialogueBox_dialog_box_closed():
	if scene_sequence_index == 0:
		background.color = orig_color
		if day == 1:
			$DialogueBoxHolder/DialogueBox/CharacterVoice.set_sounds(protester_sounds)
			$DialogueBoxHolder/DialogueBox.trigger_dialogue(prostester_dialogue)
			protester.visible = true
		elif day == 2:
			$DialogueBoxHolder/DialogueBox/CharacterVoice.set_sounds(protester_sounds)
			$DialogueBoxHolder/DialogueBox.trigger_dialogue(prostester_dialogue)
			protester.visible = true
		$DialogueBoxHolder/DialogueBox.play_sounds_in_batch = true
		narrator.visible = false
		scene_sequence_index += 1
	elif scene_sequence_index == 1:
		if day == 1:
			game_data.current_level = day + 1
			# all data from level 1 is written to disk here and only here
			game_data.save_progression()
			var _scene = get_tree().change_scene(next_scene)
		elif day == 2:
			$DialogueBoxHolder/DialogueBox/CharacterVoice.set_sounds(visitor_sounds)
			$DialogueBoxHolder/DialogueBox.play_sounds_in_batch = true
			$DialogueBoxHolder/DialogueBox.trigger_dialogue(visitor_dialogue)
			visitor.visible = true
		scene_sequence_index += 1
	elif scene_sequence_index == 2:
		scene_sequence_index += 1
		game_data.current_level = day + 1
		# all data from level 1 is written to disk here and only here
		game_data.save_progression()
		var _scene = get_tree().change_scene(next_scene)
		
func _on_DialogueBox_next_phrase_requested():
	if dream_sequence_index == 0:
		dream_vision.play("cut")
