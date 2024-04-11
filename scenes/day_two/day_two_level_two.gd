extends Level


var next_phrases = 0


func _on_DialogueBox_next_phrase_requested():
	next_phrases += 1
	if next_phrases == 1:
		$"../Control/Boss".visible = false
		$"../Control/Cop".visible = true
