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
		if !stream:
			set_rand_stream()
		play(0.0)

func play_stream():
	loop = true

func stop_stream():
	loop = false

func set_rand_stream():
	if len(sounds):
		stream = sounds[rand_range(0, len(sounds) - 1)]


func play_rand_segment():
	stop_stream()
	set_rand_stream()
	print("Playing stream: ", stream)
	
	play(0.0)
