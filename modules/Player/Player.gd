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
onready var shop = find_parent("Robbie").get_node("Shop")
onready var thrust_level = UI.get_node("IconSidebar/Thrust/Amount")
onready var laser_level = UI.get_node("IconSidebar/Laser/Amount")
onready var recharge_level = UI.get_node("IconSidebar/Recharge/Amount")
onready var laser = $Head/Interact/LaserGun
onready var Movement = $Head/Movement
onready var Interact = $Head/Interact

var checkpoint_padding = Vector3(0,0.5,0)
var last_checkpoint:Spatial = self

onready var subtitle_text = $Head/Subtitles/SubText
onready var logFilePlayer:AudioStreamPlayer = $LogFileAudio

var held_wire = null
var has_laser = true
var has_wings = false
var wire_health = 1
var battery = 100

func _ready():
	starting_checkpoint_node = get_node_or_null(starting_checkpoint)
	if starting_checkpoint_node.connect("tree_entered", self, "setup"):
		pass
	setup_items()
	
func setup():
	#print("player setup")
	#starting_checkpoint_node.set_this_checkpoint()
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

func setup_items():
	set_thrusters()
	set_laser()
	set_recharge()

func set_thrusters():
	Movement.jump_height = Movement.starting_jump_height + int(thrust_level.text)

func set_laser():
	Interact.get_node("LaserGun").strength = int(laser_level.text)
	
func set_recharge():
	pass

func checkpoint(new_checkpoint):
	last_checkpoint = new_checkpoint

func interact(n=1):
	#print("got hit")
	UI.remove_health(n)
	if UI.health <= 0:
		respawn()

func respawn():
	Interact.death_audio.play(0)
	UI.remove_life()
	UI.reset_health()
	UI.reset_stamina()
	
	if is_instance_valid(held_wire):
		held_wire.interact()
		held_wire = null
	if last_checkpoint.is_inside_tree():
		global_transform.origin = last_checkpoint.global_transform.origin + checkpoint_padding

func collect_spare():
	shop.funds += 1

func update_compass():
	return UI.set_compass(str(self.rotation_degrees[1] + 180))

func get_stamina():
	return UI.stamina

func adjust_stamina(n):
	return UI.adjust_stamina(n)

func play_log_file(stream:AudioStream, subtitle_texts:Array, subtitle_times:Array):
	if !logFilePlayer.playing:
		logFilePlayer.stream = stream
		logFilePlayer.play(0)
		subtitle_text.init_subtitles(subtitle_texts, subtitle_times)
