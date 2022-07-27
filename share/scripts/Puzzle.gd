extends Spatial

export var activate_node:NodePath
export(Array, NodePath) var piece_paths

var pieces = []
var connected_node:Node = null
var num_activated = 0
var is_working = false

func _ready():
	if activate_node:
		connected_node = get_node_or_null(activate_node)
	
	for piece_path in piece_paths:
		var piece = get_node_or_null(piece_path)
		if is_instance_valid(piece):
			pieces.append(piece)
			piece.connect("activated", self, "_handle_activation")
			piece.connect("deactivated", self, "_handle_deactivation")
			#print("Setup piece: ", piece)

func _handle_activation(_piece):
	num_activated += 1
	attempt_to_solve()

func _handle_deactivation(_piece):
	num_activated -= 1
	attempt_to_solve()

func attempt_to_solve():
	if num_activated == len(pieces) and is_instance_valid(connected_node):
		connected_node.work(self)
		is_working = true
		return
	is_working = false
