extends ColorRect

export var play_on_start : bool = false
export var play_sounds_in_batch : bool = true
export (String, MULTILINE) var dialogue_path = ""
export (float) var text_speed = 0.05

var dialogue

var phrase_num = 0
var finished = false

signal next_phrase_requested
signal dialog_box_closed

# functionality to replace keywords with variables in text
# Keywords are: $SCORE
onready var game_data = get_node("/root/game_data")
var special_character = "$"


func _ready():
	if play_on_start:
		start_dialogue()


func _process(_delta):
	$Continue/Indicator.visible = finished
	if Input.is_action_just_pressed("skip_dialogue"):
		if self.visible == true:
			if finished:
				next_phrase()
				emit_signal("next_phrase_requested")
			else:
				$Text.visible_characters = len($Text.text)


func start_dialogue():
	# get_parent().get_parent().is_interaction_active = true
	visible = true
	phrase_num = 0
	$Timer.wait_time = text_speed
	dialogue = get_dialogue()
	assert(dialogue, "Dialogue not found")
	next_phrase()


func get_dialogue():
	var f = File.new()
	assert(f.file_exists(dialogue_path), "File path doesn't exist")
	
	f.open(dialogue_path, File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return[]


func next_phrase() -> void:
	if phrase_num >= len(dialogue):
		#queue_free()
		visible = false
		# get_parent().get_parent().is_interaction_active = false
		emit_signal("dialog_box_closed")
		return
	
	finished = false
	
	$Name.bbcode_text = dialogue[phrase_num]["Name"]
	if special_character in dialogue[phrase_num]["Text"]:
		replace_keywords(dialogue[phrase_num]["Text"])
	else:
		$Text.bbcode_text = dialogue[phrase_num]["Text"]
	
	$Text.visible_characters = 0
	
	if play_sounds_in_batch:
		$CharacterVoice.play_batch(3)
	else:
		$CharacterVoice.play_audio()
	
	while $Text.visible_characters < len($Text.bbcode_text):
		$Text.visible_characters += 1
		$Timer.start()
		#$CharacterVoice.play_audio()
		yield($Timer, "timeout")
	
	finished = true
	phrase_num += 1
	return


func trigger_dialogue(path):
	dialogue_path = path
	start_dialogue()


func _on_continue_button_down():
	next_phrase()
	emit_signal("next_phrase_requested")


func _on_skip_area_button_down():
	if self.visible == true:
		if finished:
			next_phrase()
			emit_signal("next_phrase_requested")
		else:
			$Text.visible_characters = len($Text.text)
	# tried emulating button press here, didn't work
#	print("skip key pressed")
#	var a = InputEventKey.new()
#	a.scancode = KEY_ENTER
#	a.pressed = true # change to false to simulate a key release
#	Input.parse_input_event(a)
#	a.pressed = false
#	$skip_area/skip_key_release.start()


# This checks if the phrase contains a keyword that should be changed into a variable
func replace_keywords(phrase):
	var new_phrase
	if "$SCORE" in phrase:
		new_phrase = phrase.replace("$SCORE", String(game_data.current_score))
	# Add other keywords here
	$Text.bbcode_text = new_phrase
