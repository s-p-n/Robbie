extends AudioStreamPlayer3D

export var loop = false
export var is_active = false

func _process(delta):
	if is_active and !playing:
		play(0.0)

func play_stream():
	is_active = true

func stop_stream():
	is_active = false
