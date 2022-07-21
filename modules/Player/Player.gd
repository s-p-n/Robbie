extends KinematicBody

# Emits process(delta) signal and input(event) signal.
# The process one emits every _process() call, 
# and the input(event) one maps directly to _input.
# You get the idea.

signal process(delta)
signal input(event)

var checkpoint_padding = Vector3(0,0.5,0)
var last_checkpoint:Vector3

func _ready():
	checkpoint()

func _input(event):
	emit_signal("input", event)

func _process(delta):
	emit_signal("process", delta)

func checkpoint():
	last_checkpoint = global_transform.origin + checkpoint_padding

func respawn():
	global_transform.origin = last_checkpoint
