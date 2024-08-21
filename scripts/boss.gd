extends Character

signal boss_clicked

var boss_health
var boss_annoyance = 0 # tie boss annoyance to an angry sprite
var annoyance_treshold = 3
var timer


func _ready():
	if frames != load("res://animation/boss_faces.tres"):
		frames = load("res://animation/boss_faces.tres")
	boss_health = game_data.boss_health
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "hurt_window")


func clicked():
	if can_talk_to:
		# pause the timer here
		emit_signal("boss_clicked")
		var current_tool = player_status.current_tool
		print(current_tool)
		
		# player has nothing equipped
		if current_tool == 0:
			current_level.prompt_end()
			
		# player has the saw equipped
		elif current_tool == 1:#$"../../player_status".saw:
			boss_health -= 1
			play("hurt")
			timer.start(1)
			boss_annoyance += 1
			if boss_health == 0:
				$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/hit_boss_dead.json")
				can_talk_to = false
				current_dialogue = "hit_boss_dead"
			else:
				if boss_annoyance < annoyance_treshold:
					$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/hit_boss.json")
					if boss_annoyance == annoyance_treshold - 1:
						$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/hit_boss_last_warning.json")
					can_talk_to = false
					current_dialogue = "hit_boss"
					current_level.boss_just_hurt = true
				else:
					$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/hit_boss_fired.json")
					can_talk_to = false
					current_dialogue = "hit_boss_fired"
		
		# player has the tape equipped
		elif current_tool == 2:
			$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/special/boss_tape_reaction.json")
		game_data.boss_health = boss_health


func _on_boss_button_button_down():
	clicked()


# Let's observe the boss dialogue box closing here
# We want to trigger special conditions when he's hurt by the saw
func _on_DialogueBox_dialog_box_closed():
	if current_dialogue != null:
		if current_dialogue == "hit_boss_fired":
			var _x = get_tree().change_scene("res://scenes/game_over/game_over.tscn")
		if current_dialogue == "hit_boss_dead":
			var _x = get_tree().change_scene("res://scenes/outro_boss_dead.tscn")
		can_talk_to = true
		current_dialogue = null


func hurt_window():
	play("default")
	if boss_annoyance >= annoyance_treshold:
		play("happy")


# The player is replaying a level so the boss should always be visible
func make_boss_stay():
	can_talk_to = true
