extends RigidBody
onready var pylon
var open = false
var time_since = 0.0 # - 4.8
var z_open_lim
var z_closed_lim
var at_limit = true
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	z_closed_lim = global_transform.origin.z
	z_open_lim = global_transform.origin.z
	open = false
	pylon = get_parent()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pylon.is_powered:
		time_since += delta
		if time_since > (delta * 5):
			open = true
			at_limit = false
	else:
		time_since = 0.0
		open = false
	
	print("Parent has power: ", pylon.is_powered, "      Open: ", open, "\nTime Since: ", time_since)
	
	
	if open and !at_limit:
		print("Open!")
		move_to_open(delta)
		
	if (global_transform.origin.z <= z_closed_lim) or (global_transform.origin.z >= z_open_lim):
		at_limit = true


func move_to_open(delta):	
	if open:
		global_transform.origin.z = lerp(global_transform.origin.z, -5.8, delta * .27)
	else:
		global_transform.origin.z = lerp(global_transform.origin.z, 3, delta * .27)
