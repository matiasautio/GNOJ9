extends AudioStreamPlayer


var sounds = []
var sound_directory = Directory.new()
export var sound_files_path = "res://sounds/boss_voices/"
export var yes_interruptions: bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	load_sounds()


func load_sounds():
	sound_directory.open(sound_files_path)
	sound_directory.list_dir_begin(true)
	var sound = sound_directory.get_next()
	while sound != "":
		if !".import" in sound:
			sounds.append(load(sound_files_path + sound))
		sound = sound_directory.get_next()


func play_audio():
	if !playing or yes_interruptions:
		stream = sounds[randi() % sounds.size()]
		play()


func reset_sounds():
	sounds = []
	load_sounds()
