extends AudioStreamPlayer

export(Array, AudioStream) var sounds
export var yes_interruptions: bool = true

var batch_play_active = false
var batch_counter = 0
var batch_target = 0


func _physics_process(_delta):
	if batch_play_active and batch_counter < batch_target:
		if !playing:
			stream = sounds[randi() % sounds.size()]
			play()
			batch_counter += 1
	if batch_counter >= batch_target:
		batch_counter = 0
		batch_play_active = false


func play_audio():
	if !playing or yes_interruptions:
		stream = sounds[randi() % sounds.size()]
		play()


func play_batch(batch_size: int):
	batch_play_active = true
	batch_target = batch_size
