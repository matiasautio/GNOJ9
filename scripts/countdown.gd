extends RichTextLabel


onready var time_text = self
#onready var stopwatch = get_node("/root/Data").get_node("stopwatch")
const max_elapsed_time = 20
export var countdown_length = 30
var stopwatch = 0
var current_time = 0
var time_left
const text_start = "[center]"
const text_end = "[/center]"
var orig_color
var can_reset = true

var countdown = true

var times_played = 0


func _ready():
	orig_color = time_text.modulate
	time_left = countdown_length
	#start_countdown()


func _process(delta):
	pass
#	if countdown:
#		can_reset = true
#		stopwatch -= delta
#		time_left = int(stopwatch)
#		#time_left -= current_time
#		if current_time >= max_elapsed_time:
#			time_text.modulate = Color(0.984,0.204,0.039, 1)
#		if current_time >= countdown_length:
#			countdown = false
#		time_text.bbcode_text = text_start + String(time_left ) + text_end
#		print(time_left)
#		print(current_time)
#	elif !stopwatch.use_stopwatch and can_reset :
#		can_reset = false
#		current_time = 0
#		time_text.modulate = orig_color
#		time_text.bbcode_text = text_start + "0" + text_end


func start_countdown():
	$countdown_timer.start()


func _on_countdown_timer_timeout():
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
		if times_played == 1:
			$"../../level_two".prompt_end(1)
		else:
			$"../../level_two".prompt_end(0)
		
