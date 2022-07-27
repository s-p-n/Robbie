extends AudioStreamPlayer

signal finished_playing(node)

func _ready():
	if connect("finished", self, "_on_finish"):
		print("Warning: Footstep Audio failed to connect signal")

func _on_finish():
	emit_signal("finished_playing", self)
