extends RigidBody
onready var start_points = $StartPoints
onready var end_points = $EndPoints
onready var wires


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	wires = find_parent("root").find_node('Wires')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_linear_velocity(lerp(get_linear_velocity(), Vector3(0,0,0), delta))
	var wire_start_points = start_points.get_children()
	for wire_point in wire_start_points:
		var wire = wires.get_child(wire_point.index_id)
		if wire:
			wire.set_translation(wire_point.global_transform.origin)
		
	var wire_end_points = end_points.get_children()
	for wire_point in wire_end_points:
		var wire = wires.get_child(wire_point.index_id)
		if wire:
			wire.stop_position.global_transform.origin = (wire_point.global_transform.origin)
		
