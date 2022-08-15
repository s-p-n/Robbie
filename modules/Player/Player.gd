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

var held_wire = null
var has_laser = false
var has_wings = false

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
	var last_collision:KinematicCollision = get_last_slide_collision()
	if is_instance_valid(last_collision):
		var collider = last_collision.collider
		if is_instance_valid(collider):
			if collider.name == "LazerBeam":
				pass
				#collider.turn_off()
				#interact()

func checkpoint(new_checkpoint):
	last_checkpoint = new_checkpoint

func interact():
	print("got hit")
	UI.remove_health()
	if UI.health <= 0:
		respawn()

func respawn():
	UI.remove_life()
	UI.reset_health()
	if is_instance_valid(held_wire):
		held_wire.interact()
		held_wire = null
	if last_checkpoint.is_inside_tree():
		global_transform.origin = last_checkpoint.global_transform.origin + checkpoint_padding

func give_power(power):
	print("Player gained the power of: ", power)
	
	match power:
		"Laser Gun":
			has_laser = true
			return
		"Extra Life":
			return UI.add_life()
		"Wings":
			has_wings = true
			return

func get_stamina():
	return UI.stamina

func adjust_stamina(n):
	return UI.adjust_stamina(n)
