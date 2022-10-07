extends KinematicBody

onready var WireStartPos = $StartPoint
onready var WireEndPos = $EndPoint

onready var parent = get_parent()
onready var player = parent.player

func _ready():
	player.connect("process", self, "look_at_target")

func look_at_target(_delta):
	if !is_instance_valid(parent):
		#print("Wire lost Powerline, disabling tick listener.")
		player.disconnect("process", self, "look_at_target")
		return
	
	if !is_inside_tree():
		#print("Wire lost Powerline, disabling tick listener.")
		player.disconnect("process", self, "look_at_target")
		return
	
	var target = get_next()
	var looking_at = global_transform.looking_at(target, Vector3(0,1,0))
	var collision = move_and_collide(Vector3(0,0,0))
	force_in_place()
	if is_instance_valid(collision):
		var collider = collision.get_collider()
		
		if !(collider is KinematicBody) and parent.pair[0].pylon != collider and (!parent.pair[1] or parent.pair[1].pylon != collider):
			print('wire collision: ', collider)
			parent.disconnect_pair()
	
	look_at(target, Vector3(0,1,0))
	
	if is_instance_valid(parent.pair[1]):
		if global_transform.is_equal_approx(looking_at):
			#print("Wires in place, disabling tick listener.")
			player.disconnect("process", self, "look_at_target")

func get_prev():
	var prev = get_prev_wire()
	if !is_instance_valid(prev):
		return parent.pair[0].global_transform.origin
	return prev.WireEndPos.global_transform.origin

func get_next():
	var next = get_next_wire()
	if !is_instance_valid(next):
		if parent.pair[1]:
			return parent.pair[1].global_transform.origin
		else:
			return parent.player_pos
	return next.WireStartPos.global_transform.origin

func get_prev_wire():
	var idx = get_index()
	if idx == 0:
		return null
	return parent.get_child(idx - 1)

func get_next_wire():
	var idx = get_index()
	if idx == parent.get_child_count() - 1:
		return null
	return parent.get_child(idx + 1)

func get_siblings():
	return parent.get_children()

func find_ideal_position():
	var a = parent.pair[0].global_transform.origin
	var b
	
	if parent.pair[1]:
		b = parent.pair[1].global_transform.origin
	else:
		b = parent.player_pos

	var my_bias = float(get_index()) / float(parent.get_child_count())
	
	var sag = Vector3(0, abs(0.5 - my_bias) * abs(0.5 - my_bias), 0)
	
	var ideal_pos = (a - (a - b) * my_bias)
	return ideal_pos + sag


func force_in_place():
	global_transform.origin = find_ideal_position()
