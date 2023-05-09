extends Node2D


onready var background = $BackgroundColor
var orig_color
var dream_color = "023548"

var dream_sequence_index = 0
onready var dream_vision = $dream_vision

var scene_sequence_index = 0

onready var narrator = $NarratorFace
onready var protester = $Protester

# Called when the node enters the scene tree for the first time.
func _ready():
	orig_color = background.color
	background.color = dream_color


func _on_DialogueBox_dialog_box_closed():
	if scene_sequence_index == 0:
		background.color = orig_color
		$DialogueBoxHolder/DialogueBox/CharacterVoice.sound_files_path = "res://sounds/boss_voices/"
		$DialogueBoxHolder/DialogueBox/CharacterVoice.reset_sounds()
		$DialogueBoxHolder/DialogueBox.trigger_dialogue("res://dialogue/protester_visit.json")
		narrator.visible = false
		protester.visible = true
		scene_sequence_index += 1
	elif scene_sequence_index == 1:
		scene_sequence_index += 1
		var _scene = get_tree().change_scene("res://scenes/credits/credits.tscn")
		
func _on_DialogueBox_next_phrase_requested():
	if dream_sequence_index == 0:
		dream_vision.play("cut")
