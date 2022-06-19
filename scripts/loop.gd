extends AudioStreamPlayer3D

export(Array, AudioStream) var sounds = []

export var loop = false

func _ready():
	if loop:
		playing = true

func _process(_delta):
	if loop and !playing:
		play(0.0)

func play_stream():
	loop = true

func stop_stream():
	loop = false
