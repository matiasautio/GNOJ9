extends RichTextLabel


onready var time_text = self
const max_elapsed_time = 20
export var countdown_length = 30
var time_left
const text_start = "[center]"
const text_end = "[/center]"
var orig_color
var can_countdown = true
var times_played = 0


func _ready():
	orig_color = time_text.modulate
	time_left = countdown_length
	time_text.bbcode_text = text_start + "[wave]" + String(time_left ) + "[/wave]" + text_end
	#start_countdown()


func start_countdown():
	$countdown_timer.start()
	can_countdown = true
	orig_color = time_text.modulate
	time_left = countdown_length
	time_text.bbcode_text = text_start + String(time_left ) + text_end


func pause_countdown():
	can_countdown = false
	$countdown_timer.stop()
	time_text.bbcode_text = text_start + "[wave]" + String(time_left ) + "[/wave]" + text_end


func _on_countdown_timer_timeout():
	if can_countdown:
		if time_left > 0:
			time_left -= 1
			time_text.bbcode_text = text_start + String(time_left ) + text_end
			if time_left == 10:
				time_text.modulate = Color(0.875,0.592,0.02,1)
			$countdown_timer.start()
		elif time_left == 0:
			times_played += 1
			time_left = countdown_length
			time_text.modulate = orig_color
			$"../../level_two".prompt_end(times_played)
#			if times_played == 1:
#				$"../../level_two".prompt_end(1)
#			else:
#				$"../../level_two".prompt_end(0)
