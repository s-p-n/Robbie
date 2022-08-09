extends AudioStreamPlayer3D

export(Array, AudioStream) var sounds = []

export var loop = false
var rand_sound = null

func _ready():
	if stream:
		sounds.append(stream)
	if loop:
		playing = true

func _process(_delta):
	
	if loop and !playing:
		if len(sounds):
			if !rand_sound:
				rand_sound = sounds[
					rand_range(0, len(sounds) - 1)]
				stream = rand_sound
		play(0.0)

func play_stream():
	
	loop = true

func stop_stream():
	loop = false

func get_stream():
	stream = sounds[rand_range(0, len(sounds) - 1)]
