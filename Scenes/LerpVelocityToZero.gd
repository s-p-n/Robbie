extends RigidBody
onready var start_points = $StartPoints
onready var end_points = $EndPoints
onready var wires
var wires_attached = []

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	wires = get_tree().current_scene.find_node('Wires')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_wires_attached = []
	set_linear_velocity(lerp(get_linear_velocity(), Vector3(0,0,0), delta))
	var wire_start_points = start_points.get_children()
	for wire_point in wire_start_points:
		var wire = wires.get_child(wire_point.index_id)
		if wire.visible:
			new_wires_attached.append(wire_point.index_id)
			wire.set_translation(wire_point.global_transform.origin)
		
	var wire_end_points = end_points.get_children()
	for wire_point in wire_end_points:
		var wire = wires.get_child(wire_point.index_id)
		if wire.visible:
			if not wire_point.index_id in new_wires_attached:
				new_wires_attached.append(wire_point.index_id)
			wire.stop_position.global_transform.origin = (wire_point.global_transform.origin)
	
	wires_attached = new_wires_attached
	if len(wires_attached) > 0:
		print(wires_attached)
