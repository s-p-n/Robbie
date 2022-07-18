extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var powered_wires = get_source_wires()
	powered_wires = get_connected_wires(powered_wires)
	set_pylon_power(powered_wires)
	if len(powered_wires) > 0:
		#print(powered_wires)
		pass

func get_source_wires():
	var active_sources = []
	for pylon in get_child(0).get_children():
		if pylon.is_source:
			var source_wires = pylon.get_wires()
			if len(source_wires) > 0:
				for index_number in source_wires:
					if not index_number in active_sources:
						active_sources.append(index_number)
	return active_sources

func get_connected_wires(wire_id_array):
	# wire_id_array is an array of wires attached to power sources
	var new_wire_id_array = wire_id_array
	for wire_id in wire_id_array:
		for pylon in get_children():
			if wire_id in pylon.get_wires():
				for pylon_wire_id in pylon.get_wires():
					if not pylon_wire_id in new_wire_id_array:
						new_wire_id_array.append(pylon_wire_id)
	if len(new_wire_id_array) > len(wire_id_array):
		return get_connected_wires(new_wire_id_array)
	else:
		return new_wire_id_array

func reset_pylons():
	for pylon in get_children():
		if not pylon.is_source:
			pylon.is_powered = false
			pylon.power_light.visible = false
			
func set_pylon_power(powered_wires):
	reset_pylons()
	for pylon in get_children():
		if not pylon.is_source:
			for wire in powered_wires:
				for pylon_wire in pylon.get_wires():
					if wire == pylon_wire:
						pylon.is_powered = true
						pylon.power_light.visible = true
					
