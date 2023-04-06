extends AnimatedSprite


var is_present = true
var can_talk_to
var boss_health
var boss_annoyance = 0
var annoyance_treshold = 3

var current_dialogue = null
var current_level

func _ready():
	boss_health = get_node("/root/game_data").boss_health


func boss_clicked():
	if can_talk_to:
		var current_tool = $"../../player_status".current_tool
		if current_level == 1:
			if current_tool == $"../../player_status".none:
				$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/level_one_continue.json")
				$"../../level_one".next_level()
				# current_dialogue = "level_one_continue"
			elif current_tool == $"../../player_status".saw:
				boss_health -= 1
				boss_annoyance += 1
				if boss_health == 0:
					$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/hit_boss_dead.json")
					can_talk_to = false
					current_dialogue = "hit_boss_dead"
				else:
					if boss_annoyance < annoyance_treshold:
						$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/hit_boss.json")
						can_talk_to = false
						current_dialogue = "hit_boss"
					else:
						$"../DialogueBoxHolder/DialogueBox".trigger_dialogue("res://dialogue/hit_boss_fired.json")
						can_talk_to = false
						current_dialogue = "hit_boss_fired"
		elif current_level == 2:
			pass
		get_node("/root/game_data").boss_health = boss_health


func _on_boss_button_button_down():
	boss_clicked()


# Let's observe the boss dialogue box closing here
# We want to trigger special conditions when he's hurt by the saw
func _on_DialogueBox_dialog_box_closed():
	if current_dialogue != null:
		if current_dialogue == "hit_boss_fired":
			get_tree().change_scene("res://scenes/main_menu.tscn")
		if current_dialogue == "hit_boss_dead":
			get_tree().change_scene("res://scenes/main_menu.tscn")
		can_talk_to = true
		current_dialogue == null


func toggle_status():
	if is_present:
		is_present = false
		self.play("away")
	else:
		is_present = true
		self.play("default")
