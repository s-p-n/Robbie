extends Spatial

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
var lowest_y = 0

func set_interact(new_interact):
	interact = new_interact
	player = interact.player
	clip_wire_audio = player.get_node_or_null("Sounds/WireCutAudio")
	PowerLines = player.find_parent("Robbie").get_node("PowerLines")
	PowerLines.add_child(self)
	
	if !interact.connect("tick", self, "update_wires"):
		# Could handle error-case
		pass
	
func begin(new_ray):
	ray = new_ray
	pair[0] = ray.get_collider()
	global_transform.origin = ray.get_collision_point()
	lowest_y = pair[0].global_transform.origin.y - 0.5
	print("lowest y:", lowest_y)
	add_wire()

func add_wire():
	var wire = WireScene.instance()
	add_child(wire)
	adjust_wires()

func update_wires(_delta):
	if !pair[1]:
		player_pos = player.get_node("Head").global_transform.origin + head_offset
		update_num_wires(player.global_transform.origin)
	else:
		print("Powerline in place, disabling tick listener.")
		interact.disconnect("tick", self, "update_wires")
	
func end(_ray):
	var end_point = _ray.get_collision_point()
	pair[1] = _ray.get_collider()
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
	print(pair)
	print(pair[0].pylon and pair[0].pylon.has_method("connect_wire_to"))
	print(pair[1].pylon and pair[1].pylon.has_method("connect_wire_to"))

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
