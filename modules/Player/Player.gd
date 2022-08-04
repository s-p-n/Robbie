extends KinematicBody

# Emits process(delta) signal and input(event) signal.
# The process one emits every _process() call, 
# and the input(event) one maps directly to _input.
# You get the idea.

signal process(delta)
signal input(event)

export var starting_checkpoint:NodePath
var starting_checkpoint_node:RigidBody

onready var checkpoint_pos = global_transform.origin
onready var UI = find_parent("Robbie").get_node("UI")
var checkpoint_padding = Vector3(0,0.5,0)
var last_checkpoint:Spatial = self

func _ready():
	starting_checkpoint_node = get_node(starting_checkpoint)
	if starting_checkpoint_node.connect("tree_entered", self, "setup"):
		pass

func setup():
	starting_checkpoint_node.set_this_checkpoint()
	respawn()

func _input(event):
	emit_signal("input", event)

func _process(delta):
	emit_signal("process", delta)

func checkpoint(new_checkpoint):
	last_checkpoint = new_checkpoint

func interact():
	UI.remove_health()
	if UI.health <= 0:
		respawn()

func respawn():
	UI.reset_health()
	global_transform.origin = last_checkpoint.global_transform.origin + checkpoint_padding
