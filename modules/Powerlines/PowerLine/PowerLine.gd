extends Spatial

signal move(delta)

const WIRE_LENGTH = 0.19

export var WireScene:PackedScene

onready var wireWhole = get_node("WireWhole")

var head_offset =  Vector3(0, -0.6, 0)
var PowerLines:Spatial
var interact:Node
var entity:KinematicBody
var ray:RayCast
var clip_wire_audio:AudioStreamPlayer
var place_wire_audio:AudioStreamPlayer
var pair = [null, null]
var entity_pos:Vector3
var lowest_y = -3
var old_transform_a
var old_transform_b

var throttle:float = 0.2
var time:float = 0

var size_cache = [Vector3.ZERO, Vector3.ZERO, 1.0]

func set_interact(new_interact):
	interact = new_interact
	entity = interact.entity
	clip_wire_audio = interact.get_node_or_null("Sounds/WireClipAudio")
	place_wire_audio = interact.get_node_or_null("Sounds/WirePlaceAudio")
	PowerLines = entity.find_parent("Robbie").get_node("PowerLines")
	PowerLines.add_child(self)
	
	if !interact.connect("tick", self, "update_wires"):
		# Could handle error-case
		pass
	
func begin(input):
	pair[0] = input
	entity.held_wire = wireWhole
	global_transform.origin = pair[0].global_transform.origin
	place_wire_audio.play(0.0)

func add_wire():
	var wire = WireScene.instance()
	add_child(wire)
	adjust_wires()

func update_wires(delta):
	if pair[0]:
		var up = Vector3(0,1,0)
		var start_pos:Vector3
		var end_pos:Vector3
		
		wireWhole.global_transform.origin = lerp(wireWhole.global_transform.origin, pair[0].global_transform.origin, delta * 25)
		
		if !is_instance_valid(pair[1]):
			start_pos = wireWhole.global_transform.origin
			end_pos = entity.global_transform.origin
		else:
			#print('powerline collisions: ', wireWhole.get_colliding_bodies())
			start_pos = wireWhole.global_transform.origin
			end_pos = pair[1].global_transform.origin
		
		# Using a cache for the wire size, to prevent division
		# of the distance for wires that already have been calculated.
		if size_cache[0] != start_pos or size_cache[1] != end_pos:
			if not wireWhole.global_transform.origin.direction_to(end_pos).is_equal_approx(up):
				wireWhole.look_at(end_pos, up)
			size_cache[0] = start_pos
			size_cache[1] = end_pos
			size_cache[2] = start_pos.distance_to(end_pos) / 5
		
		# If the size is close (from lerping)
		if is_equal_approx(wireWhole.scale.z, size_cache[2]):
			# If the size isn't exactly right, snap it to place.. once.
			if wireWhole.scale.z != size_cache[2]:
				wireWhole.scale.z = size_cache[2]
		else:
			# Animate wire size
			wireWhole.scale.z = lerp(wireWhole.scale.z, size_cache[2], delta * 25)
		

func update_wires_old(delta):
	time += delta
	if time < throttle:
		return
	time = 0
	
	if !pair[1]:
		entity_pos = entity.get_node("Head").global_transform.origin + head_offset
		#update_lowest_y()
		if pair[0]:
			var new_transform_a = pair[0].global_transform.origin
			var new_transform_b = entity_pos
			if old_transform_a != new_transform_a or old_transform_b != new_transform_b:
				global_transform.origin = new_transform_a
				update_num_wires(entity_pos)
				emit_signal("move", delta)
				old_transform_a = new_transform_a
				old_transform_b = entity_pos
				
				
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
	
func end(input):
	pair[1] = input
	entity.held_wire = null
	wireWhole.set_collision_layer_bit(0, true)
	#interact.disconnect("tick", self, "update_wires")
	#var end_point = pair[1].global_transform.origin
	#update_num_wires(end_point)
	#setup_powerline_collision()
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
			if pair[1].pylon.output_color == pair[0].pylon.input_color:
				wireWhole.material.albedo_color = pair[1].pylon.output_color
			elif pair[0].pylon.output_color != pair[1].pylon.input_color:
				print("color mismatch!")
				print(pair[0].pylon.output_color)
				print(pair[1].pylon.input_color)
				# TODO:
				# removing destroy causes the wire connection to be made because connect_pair has already been called.
				# Need to fix this later
				# Audio is too quiet for robot talking.
				interact.wire_mismatch_audio.get_stream()
				interact.wire_mismatch_audio.play(0.0)
				return destroy()
			place_wire_audio.play(0.0)
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
		b = entity.get_node("Head").global_transform.origin.y + head_offset.y
	
	lowest_y = min(a, b) - 2
	print('low y:', lowest_y)
	print(a)
	print(b)
	lowest_y = -2
