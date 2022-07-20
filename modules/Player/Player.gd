extends KinematicBody

# Emits process(delta) signal and input(event) signal.
# The process one emits every _process() call, 
# and the input(event) one maps directly to _input.
# You get the idea.

signal process(delta)
signal input(event)

func _input(event):
	emit_signal("input", event)

func _process(delta):
	emit_signal("process", delta)
