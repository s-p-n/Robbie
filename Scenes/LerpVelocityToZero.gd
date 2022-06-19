extends RigidBody
onready var start_points = $StartPoints
onready var end_points = $EndPoints
onready var power_light = $PowerLight
onready var audio = get_node_or_null("play_when_powered")
onready var wires
var wires_attached = []
var is_powered = false
var is_source
var power_source = null


# Called when the node enters the scene tree for the first time.
func _ready():
	power_light.visible = false
	is_powered = false
	is_source = false
	wires = get_tree().current_scene.find_node('Wires')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if is_source:
		if !power_source or !power_source.is_powered:
			is_source = false
		else:
			is_powered = true
	
	if is_powered:
		if audio and !audio.loop:
			audio.play_stream()
		power_light.visible = true
	else:
		if audio and audio.loop:
			audio.stop_stream()
		power_light.visible = false
	
	var new_wires_attached = []
	set_linear_velocity(Vector3(0,0,0))
	
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

func set_power_source(source):
	if source and source.is_powered:
		power_source = source
		is_source = true;

func get_wires():
	return wires_attached
