extends Spatial

export var speed = 15
var cur_rotation = 0
onready var blade = find_node("blade")

onready var audio_stream = get_parent().find_node("Sound")

export var is_spinning = true
onready var pylon = get_parent()
var time_since = 0.0
const no_power_timeout = 1;
# Called when the node enters the scene tree for the first time.

func _ready():
	is_spinning = pylon.is_powered


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	attempt_spin(delta)

func check_power(delta):
	if !is_spinning and !pylon.is_powered:
		time_since = 0.0
	elif is_spinning and pylon.is_powered:
		time_since = 0.0
	elif !is_spinning and pylon.is_powered:
		is_spinning = true
		time_since = 0.0
	elif is_spinning and !pylon.is_powered:
		time_since += delta
		if time_since >= no_power_timeout:
			is_spinning = false
			time_since = 0.0
	return is_spinning

func attempt_spin(delta):
	cur_rotation = blade.rotation.z
	var t = delta * speed * 0.05
	if check_power(delta):
		cur_rotation = lerp(cur_rotation, cur_rotation + speed, t)
		#loop_sound()
	else:
		cur_rotation = lerp(cur_rotation, 0, t)
		#stop_sound()
	blade.rotate_z(cur_rotation)

func loop_sound():
	audio_stream.play_stream()
	
func stop_sound():
	audio_stream.stop_stream()
