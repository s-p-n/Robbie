extends Spatial

export var activation_pylon:NodePath
export var rotation_speed:float = 1
export var active = false
var pylon = null

func _ready():
	pylon = get_node_or_null(activation_pylon)
	#if is_instance_valid(pylon):
	#	pylon.connect("activated", self, "work")
	#	pylon.connect("deactivated", self, "work")

func _process(delta):
	if is_instance_valid(pylon) and pylon.is_powered:
		rotate_y(delta * rotation_speed)
	
func work():
	active = !active
	print("floor working: ", active)

