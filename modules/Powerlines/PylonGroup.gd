extends Spatial

export var input_color:Color
export var output_color:Color

export var connect_children:bool
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if input_color != Color.black:
		create_pylon_gradient()
	else:
		print("Didn't setup the gradient thing")


func create_pylon_gradient():
	var num_children = get_child_count()
	var children = get_children()
	for pylon in children:
		var index = pylon.get_index()
		var input_adjustment:float = index / float(num_children)
		var output_adjustment:float = (index + 1) / float(num_children)
		var child_start_color = (input_color * (1 - input_adjustment)) + (output_color * input_adjustment)
		var child_end_color = (input_color * (1 - output_adjustment)) + (output_color * output_adjustment)
		
		setup_pylon(pylon, child_start_color, child_end_color)

func setup_pylon(pylon, start, end):
	var index = pylon.get_index()
	
	#print(index, ", ", pylon, " start: ", start, " end: ", end)
	
	pylon.input_color = start
	pylon.output_color = end
	
	if connect_children and index != 0:
		var connected_pylon = get_child(index - 1)
		while !("connected_to_pylons" in connected_pylon):
			connected_pylon = connected_pylon.get_child(connected_pylon.get_child_count() - 1)
			print(pylon, " has a new connected pylon: ", connected_pylon)
		if "connected_to_pylons" in pylon:
			
			pylon.connected_to_pylons.append(pylon.get_path_to(connected_pylon))
			pylon._ready()
		else:
			var pylon_group = pylon
			
			while !("connected_to_pylons" in pylon):
				pylon = pylon.get_child(0)
			
			pylon_group.connect_children = true
			pylon_group._ready()
			pylon.connected_to_pylons.append(pylon.get_path_to(connected_pylon))
			pylon._ready()
	
