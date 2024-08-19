extends RichTextLabel


#onready var time_text = self
#const max_elapsed_time = 20
export var countdown_length = 30
var time_left
const text_start = "[center]"
const text_end = "[/center]"
var orig_color
var can_countdown = true
var times_played = 0
var level


func _ready():
	orig_color = modulate
	time_left = countdown_length
	bbcode_text = text_start + "[wave]" + String(time_left ) + "[/wave]" + text_end
	$"../MarginContainer3/timer_header".bbcode_text = "[center]TIME[/center]"
	#start_countdown()


# when set from a level script
func init():
	time_left = countdown_length
	bbcode_text = text_start + "[wave]" + String(time_left ) + "[/wave]" + text_end
	$"../MarginContainer3/timer_header".bbcode_text = "[center]TIME[/center]"


func start_countdown():
	$countdown_timer.start()
	can_countdown = true
	orig_color = modulate
	time_left = countdown_length
	bbcode_text = text_start + String(time_left ) + text_end


func pause_countdown():
	can_countdown = false
	$countdown_timer.stop()
	bbcode_text = text_start + "[wave]" + String(time_left ) + "[/wave]" + text_end


func _on_countdown_timer_timeout():
	if can_countdown:
		if time_left > 0:
			time_left -= 1
			bbcode_text = text_start + String(time_left ) + text_end
			if time_left == 10:
				modulate = Color(0.875,0.592,0.02,1)
			$countdown_timer.start()
		elif time_left == 0:
			times_played += 1
			time_left = 0#countdown_length
			modulate = orig_color
			level.prompt_end()


func _on_Boss_boss_clicked():
	pause_countdown()
