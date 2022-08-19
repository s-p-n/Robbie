extends Spatial

export var speed:float = 4

export var max_x:float = 10
export var min_x:float = -10
export var max_z:float = 10
export var min_z:float = -10

export var north_input_path:NodePath
export var south_input_path:NodePath
export var east_input_path:NodePath
export var west_input_path:NodePath

export var north_output_path:NodePath
export var south_output_path:NodePath
export var east_output_path:NodePath
export var west_output_path:NodePath

export var is_north_source:bool
export var is_south_source:bool
export var is_east_source:bool
export var is_west_source:bool

onready var floor_platform = $platform
onready var ship_area = $Area

var bodies_inside_vehicle = []

var north_input:RigidBody
var south_input:RigidBody
var east_input:RigidBody
var west_input:RigidBody

var north_output:RigidBody
var south_output:RigidBody
var east_output:RigidBody
var west_output:RigidBody

var direction = Vector3(0,0,0)

func _ready():
	north_input = get_node_or_null(north_input_path)
	south_input = get_node_or_null(south_input_path)
	east_input = get_node_or_null(east_input_path)
	west_input = get_node_or_null(west_input_path)
	
	connect_inputs()
	
	north_output = get_node_or_null(north_output_path)
	south_output = get_node_or_null(south_output_path)
	east_output = get_node_or_null(east_output_path)
	west_output = get_node_or_null(west_output_path)
	
	setup_outputs()


func _physics_process(delta):
	var new_pos_z = transform.origin.z + direction.z
	var new_pos_x = transform.origin.x + direction.x
	
	if not (max_z >= new_pos_z and new_pos_z >= min_z):
		direction.z = 0
	
	if not (max_x >= new_pos_x and new_pos_x >= min_x):
		direction.x = 0
	
	if not direction.is_equal_approx(Vector3.ZERO):
		var velocity = direction * speed
		transform.origin = lerp(transform.origin, transform.origin + velocity, delta)
		
		
		print("Moving ", velocity)
		for body in bodies_inside_vehicle:
			body.global_transform.origin = lerp(body.global_transform.origin, body.global_transform.origin + velocity, delta)

func _handle_direction_change(_pylon):
	direction = Vector3.ZERO
	
	if north_input.is_powered and !south_input.is_powered:
		direction.z = -1
	elif south_input.is_powered and !north_input.is_powered:
		direction.z = 1
	
	if west_input.is_powered and !east_input.is_powered:
		direction.x = -1
	elif east_input.is_powered and !west_input.is_powered:
		direction.x = 1
	
	
func connect_inputs():
	if OK != north_input.connect("activated", self, "_handle_direction_change"):
		pass
	if OK != north_input.connect("deactivated", self, "_handle_direction_change"):
		pass
	if OK != south_input.connect("activated", self, "_handle_direction_change"):
		pass
	if OK != south_input.connect("deactivated", self, "_handle_direction_change"):
		pass
	if OK != east_input.connect("activated", self, "_handle_direction_change"):
		pass
	if OK != east_input.connect("deactivated", self, "_handle_direction_change"):
		pass
	if OK != west_input.connect("activated", self, "_handle_direction_change"):
		pass
	if OK != west_input.connect("deactivated", self, "_handle_direction_change"):
		pass
		
func setup_outputs():
	north_output.is_source = is_north_source
	north_output.update_power_status(north_output)
	south_output.is_source = is_south_source
	south_output.update_power_status(south_output)
	east_output.is_source = is_east_source
	east_output.update_power_status(east_output)
	west_output.is_source = is_west_source
	west_output.update_power_status(west_output)

func _on_Area_body_entered(body):
	print("enter: ", body)
	#ignore child nodes
	if !is_instance_valid(body.find_parent(name)) and !has_parent_with_collisions(body):
		bodies_inside_vehicle.append(body)

func _on_Area_body_exited(body):
	bodies_inside_vehicle.erase(body)


func has_parent_with_collisions(body):
	var parent = body.get_parent()
	while is_instance_valid(parent) and !(parent.has_method("get_collision_layer_bit") and parent.get_collision_layer_bit(0)):
		parent = parent.get_parent()
	print("body parent: ", parent)
	if is_instance_valid(parent):
		return true
	return false
