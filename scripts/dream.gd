extends Node2D


onready var game_data = get_node("/root/game_data")
onready var background = $BackgroundColor
var orig_color #3c574e
var dream_color = "023548"

var dream_sequence_index = 0
onready var dream_vision = $dream_vision

var scene_sequence_index = 0
var ready_for_next_day = false
var display_saving = false

onready var narrator = $NarratorFace
onready var protester = $Protester
onready var visitor = $Visitor

var can_grab_tool = false

# 1, 2, 3
export var day = 1
export var protester_sounds = "boss"
export var visitor_sounds = "boss"
export (String, MULTILINE) var prostester_dialogue: String = "res://dialogue/protester_visit.json"
export (String, MULTILINE) var visitor_dialogue : String = "res://dialogue/day_two/it_visit.json"
export (String, MULTILINE) var next_scene : String = "res://scenes/day_two/day_two_intro.tscn"
var game_saved_dialogue = "res://dialogue/special/developer_game_saved.json"
var game_saved_short_dialogue = "res://dialogue/special/developer_game_saved_short.json"

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
		$Protester/AnimationPlayer.play("appears")
	elif scene_sequence_index == 1:
		if day == 1:
			#trigger_save_game()
			#game_data.current_level = day + 1
			# all data from level 1 is written to disk here and only here
			#game_data.save_progression()
			#var _scene = get_tree().change_scene(next_scene)
			$FadeOut/AnimationPlayer.play("fade_out")
		elif day == 2:
			$Protester/AnimationPlayer.play_backwards("appears")
			$DialogueBoxHolder/DialogueBox/CharacterVoice.set_sounds(visitor_sounds)
			$DialogueBoxHolder/DialogueBox.play_sounds_in_batch = true
			$DialogueBoxHolder/DialogueBox.trigger_dialogue(visitor_dialogue)
			visitor.visible = true
			$Visitor/AnimationPlayer.play("appears")
		scene_sequence_index += 1
	elif scene_sequence_index == 2:
		$FadeOut/AnimationPlayer.play("fade_out")
	elif scene_sequence_index == 100:
		$FadeOut/AnimationPlayer.play("fade_out")


func trigger_save_game():
	game_data.current_level = day + 1
	game_data.save_progression()
	$DeveloperFace.visible = true
	$DialogueBoxHolder/DialogueBox/CharacterVoice.set_sounds("developer")
	if day == 1:
		$DialogueBoxHolder/DialogueBox.trigger_dialogue(game_saved_dialogue)
	elif day == 2:
		$DialogueBoxHolder/DialogueBox.trigger_dialogue(game_saved_short_dialogue)
	scene_sequence_index = 100
	ready_for_next_day = true


func _on_DialogueBox_next_phrase_requested():
	if dream_sequence_index == 0:
		dream_vision.play("cut")
	if dream_sequence_index == 4 and day == 1:
		dream_vision.visible = false
	if dream_sequence_index == 6 and day == 1:
		$tool_button/AnimationPlayer.play("increase_scale")
		$DialogueBoxHolder/DialogueBox.disconnect_skip_buttons()
	if dream_sequence_index == 4 and day == 2:
		dream_vision.visible = false
	if dream_sequence_index == 11 and day == 2:
		$tool_button/AnimationPlayer.play("increase_scale")
		$DialogueBoxHolder/DialogueBox.disconnect_skip_buttons()
	#if dream_sequence_index == 8:
		#$tool_button/AnimationPlayer.disconnect("animation_finished",self, "_on_AnimationPlayer_animation_finished")
		#$tool_button/AnimationPlayer.play_backwards("increase_scale")
	dream_sequence_index += 1
	#print(dream_sequence_index)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "increase_scale":
		can_grab_tool = true
		$tool_button/AnimationPlayer.play("pump_scale")
		$DialogueBoxHolder/DialogueBox._on_skip_area_button_down()


func _on_tool_button_pressed():
	if can_grab_tool:
		can_grab_tool = false
		#$DialogueBoxHolder/DialogueBox/Text.visible_characters = len($DialogueBoxHolder/DialogueBox/Text.text)
		#$DialogueBoxHolder/DialogueBox.finished = true
		$tool_button/AnimationPlayer.disconnect("animation_finished",self, "_on_AnimationPlayer_animation_finished")
		$tool_button/AnimationPlayer.playback_speed = 2
		$tool_button/AnimationPlayer.play_backwards("increase_scale")
		$tool_button.disconnect("pressed", self, "_on_tool_button_pressed")
		$DialogueBoxHolder/DialogueBox._on_continue_button_down()
		yield(get_tree().create_timer(1), "timeout")
		$DialogueBoxHolder/DialogueBox.connect_skip_buttons()


func load_next_day(_anim_name):
	if _anim_name == "fade_in":
		if display_saving:
			trigger_save_game()
			return
		$DialogueBoxHolder/DialogueBox.start_dialogue()
	if _anim_name == "fade_out":
		if ready_for_next_day:
			var _scene = get_tree().change_scene(next_scene)
		$Protester.hide()
		$Visitor.hide()
		background.color = "d8c4cf"
		$FadeOut/AnimationPlayer.play("fade_in")
		display_saving = true
