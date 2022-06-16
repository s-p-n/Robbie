extends Spatial

export var speed = 15
var cur_rotation = 0
onready var blade = find_node("blade")
export var is_spinning = true
onready var pylon = get_parent()
var time_since = 0.0
# Called when the node enters the scene tree for the first time.

func _ready():
	is_spinning = pylon.is_powered


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_power()
	if !is_spinning:
		cur_rotation = lerp(cur_rotation, 0, delta * speed * 0.05)
	else:
		time_since = 0.0
		cur_rotation = lerp(cur_rotation, delta * speed, delta*speed*0.5)
	blade.rotate_z(cur_rotation)

func check_power():
	is_spinning = pylon.is_powered

