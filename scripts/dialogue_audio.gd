extends AudioStreamPlayer

var sounds = []
export(Array, AudioStream) onready var boss_sounds
export(Array, AudioStream) onready var dream_sounds
export(Array, AudioStream) onready var protester_sounds
export var yes_interruptions: bool = true

# characters = boss, dream, protester
export var character = "boss"

var batch_play_active = false
var batch_counter = 0
var batch_target = 0


func _ready():
	set_sounds(character)


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


func set_sounds(sound_set):
	stop()
	sounds = []
	if sound_set == "boss":
		sounds = boss_sounds
	elif sound_set == "dream":
		sounds = dream_sounds
	elif sound_set == "protester":
		sounds = protester_sounds
