extends Spatial

signal move(delta)

const WIRE_LENGTH = 0.2

export var WireScene:PackedScene
var head_offset =  Vector3(0, -0.6, 0)
var PowerLines:Spatial
var interact:Node
var player:KinematicBody
var ray:RayCast
var clip_wire_audio:AudioStreamPlayer
var pair = [null, null]
var player_pos:Vector3
var lowest_y = -3
var old_transform_a
var old_transform_b

var throttle:float = 0.2
var time:float = 0

func set_interact(new_interact):
	interact = new_interact
	player = interact.player
	clip_wire_audio = interact.get_node_or_null("Sounds/WireClipAudio")
	PowerLines = player.find_parent("Robbie").get_node("PowerLines")
	PowerLines.add_child(self)
	
	if !interact.connect("tick", self, "update_wires"):
		# Could handle error-case
		pass
	
func begin(new_ray):
	ray = new_ray
	pair[0] = ray.get_collider()
	global_transform.origin = pair[0].global_transform.origin
	
	#update_lowest_y()
	add_wire()

func add_wire():
	var wire = WireScene.instance()
	add_child(wire)
	adjust_wires()

func update_wires(delta):
	time += delta
	if time < throttle:
		return
	time = 0
	
	if !pair[1]:
		player_pos = player.get_node("Head").global_transform.origin + head_offset
		#update_lowest_y()
		if pair[0]:
			var new_transform_a = pair[0].global_transform.origin
			var new_transform_b = player_pos
			if old_transform_a != new_transform_a or old_transform_b != new_transform_b:
				global_transform.origin = new_transform_a
				update_num_wires(player_pos)
				emit_signal("move", delta)
				old_transform_a = new_transform_a
				old_transform_b = player_pos
				
				
	elif pair[0] and pair[1]:
		var new_transform_a = pair[0].global_transform.origin
		var new_transform_b = pair[1].global_transform.origin
		
		if old_transform_a != new_transform_a or old_transform_b != new_transform_b:
			global_transform.origin = new_transform_a
			#print("changed")
			#update_lowest_y()
			update_num_wires(new_transform_b)
			emit_signal("move", delta)
				
		old_transform_a = new_transform_a
		old_transform_b = new_transform_b
	
func end(_ray):
	pair[1] = _ray.get_collider()
	var end_point = pair[1].global_transform.origin
	update_num_wires(end_point)
	setup_powerline_collision()
	connect_pair()

func update_num_wires(end_point):
	var total:int = calculate_total_wires(end_point)
	var num_wires:int = get_child_count()
	
	while total != num_wires:
		if num_wires > total:
			remove_child(get_child(num_wires - 1))
		else:
			add_wire()
		num_wires = get_child_count()
		
	adjust_wires()

func adjust_wires():
	for wire in get_children():
		wire.force_in_place()

func setup_powerline_collision():
	for wire in get_children():
		wire.set_collision_layer_bit(0, true)

func connect_pair():
	if pair[0] and pair[0].pylon and pair[0].pylon.has_method("connect_wire_to"):
		if pair[1] and pair[1].pylon and pair[1].pylon.has_method("connect_wire_to"):
			#if pair[0].pylon.is_powered and pair[1].pylon.is_powered:
				#return destroy()
			
			pair[0].pylon.connect_wire_to(self, pair[1].pylon)
			pair[1].pylon.connect_wire_to(self, pair[0].pylon)
			return
	#print(pair)
	#print(pair[0].pylon and pair[0].pylon.has_method("connect_wire_to"))
	#print(pair[1].pylon and pair[1].pylon.has_method("connect_wire_to"))

func disconnect_pair():
	if pair[0] and pair[0].pylon and pair[0].pylon.has_method("disconnect_wire_from"):
		if pair[1] and pair[1].pylon and pair[1].pylon.has_method("disconnect_wire_from"):
			pair[0].pylon.disconnect_wire_from(self, pair[1].pylon)
			pair[1].pylon.disconnect_wire_from(self, pair[0].pylon)
			destroy()
		else:
			destroy()

func destroy():
	self.queue_free()
	clip_wire_audio.play(0.0)


func calculate_total_wires(end_point) -> int:
	return int(1 + floor((global_transform.origin.distance_to(end_point) / WIRE_LENGTH) * 1.1))

func update_lowest_y():
	var a = pair[0].global_transform.origin.y
	var b
	
	if is_instance_valid(pair[1]):
		b = pair[1].global_transform.origin.y
	else:
		b = player.get_node("Head").global_transform.origin.y + head_offset.y
	
	lowest_y = min(a, b) - 2
	print('low y:', lowest_y)
	print(a)
	print(b)
	lowest_y = -2