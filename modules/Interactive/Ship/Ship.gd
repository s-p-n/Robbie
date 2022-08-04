extends Spatial

export var speed:float = 4

export var max_x:float = 10
export var min_x:float = -10
export var max_z:float = 10
export var min_z:float = -10

export var north_path:NodePath
export var south_path:NodePath
export var east_path:NodePath
export var west_path:NodePath

var north:RigidBody
var south:RigidBody
var east:RigidBody
var west:RigidBody

var direction = Vector3(0,0,0)

func _ready():
	north = get_node_or_null(north_path)
	south = get_node_or_null(south_path)
	east = get_node_or_null(east_path)
	west = get_node_or_null(west_path)
	
	north.connect("activated", self, "_handle_direction_change")
	north.connect("deactivated", self, "_handle_direction_change")
	south.connect("activated", self, "_handle_direction_change")
	south.connect("deactivated", self, "_handle_direction_change")
	east.connect("activated", self, "_handle_direction_change")
	east.connect("deactivated", self, "_handle_direction_change")
	west.connect("activated", self, "_handle_direction_change")
	west.connect("deactivated", self, "_handle_direction_change")

func _physics_process(delta):
	var new_pos_z = global_transform.origin.z + direction.z
	var new_pos_x = global_transform.origin.x + direction.x
	
	if not (max_z >= new_pos_z and new_pos_z >= min_z):
		direction.z = 0
	
	if not (max_x >= new_pos_x and new_pos_x >= min_x):
		direction.x = 0
	
	if not direction.is_equal_approx(Vector3.ZERO):
		global_transform.origin = lerp(global_transform.origin, global_transform.origin + (direction * speed), delta)


func _handle_direction_change(_pylon):
	direction = Vector3.ZERO
	
	if north.is_powered and !south.is_powered:
		direction.z = -1
	elif south.is_powered and !north.is_powered:
		direction.z = 1
	
	if west.is_powered and !east.is_powered:
		direction.x = -1
	elif east.is_powered and !west.is_powered:
		direction.x = 1
	
	
