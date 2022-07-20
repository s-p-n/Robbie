extends Node

# Emits tick(delta) for player's process.
# See PowerLine.tscn and the script there for 
# an example of how to features and things to this.

signal tick(delta)

export var PowerLineScene:PackedScene

var player:KinematicBody
var center_dot:Sprite
var pickup_ray:RayCast
var wire_ray:RayCast
var clip_ray:RayCast
var wire_reel_audio:AudioStreamPlayer
var wire_place_audio:AudioStreamPlayer
var wire_clip_audio:AudioStreamPlayer
var held_object:Node = null
var looking_at_interactable = false
var powerline:Node = null
var is_moving = false
var last_pos = Vector3(0,0,0)
var hold_position:Position3D

func _ready():
	set_player(find_parent("Player"))

func set_player(new_player):
	player = new_player
	pickup_ray = $PickupRay
	wire_ray = $WireRay
	clip_ray = $ClipRay
	center_dot = $CenterDot
	wire_reel_audio = $Sounds/WireReelAudio
	wire_place_audio = $Sounds/WirePlaceAudio
	wire_clip_audio = $Sounds/WireClipAudio
	hold_position = $HoldPosition
	
	center_dot.visible = false
	
	#if !player.connect("input", self, "process_input"):
		# Could handle error-case
	#	pass
	
	#if !player.connect("process", self, "handle_tick"):
		# Could handle error-case
	#	pass

func _unhandled_input(event):
	var interactables = look_for_interactables()
	if event is InputEventMouseMotion:
		setup_center_dot(interactables)
	
	elif event is InputEventMouseButton and Input.is_action_just_released("leftclick"):
		var took_action = false
		
		if !is_instance_valid(powerline):
			took_action = handle_pickup_action()
		
		if !took_action and !is_instance_valid(held_object):
			took_action = handle_wire_action()
		
		if !took_action:
			took_action = handle_clip_action()

func _physics_process (delta):
	handle_move_with_wire()
	handle_held_object(delta)
	emit_signal("tick", delta)

func look_for_interactables():
	return [
		pickup_ray.get_collider(),
		wire_ray.get_collider(),
		clip_ray.get_collider()
	]

func setup_center_dot(interactables):
	# interactalbes is expected to be an array of Nodes or Nil/falsey nodes
	# using `!interactables[0]` will return True for null nodes, so we have to 
	# use 2, such as `!!interactables[0]` to get False for null nodes, and True
	# for nodes that we can interact with. Tada! we know if we can interact.
	var can_grab = !!interactables[0]
	var can_wire = !!interactables[1]
	var can_clip = !!interactables[2]
	var interacting = held_object
	if (not interacting) and (can_grab or can_wire or can_clip):
		looking_at_interactable = true
		center_dot.visible = true
	else:
		looking_at_interactable = false
		center_dot.visible = false

func handle_move_with_wire():
	if last_pos.distance_to(player.global_transform.origin) > 0.1:
		is_moving = true
		last_pos = player.global_transform.origin
	else:
		is_moving = false
	
	if is_moving and is_instance_valid(powerline):
		if not wire_reel_audio.playing:
			wire_reel_audio.playing = true
	else:
		wire_reel_audio.playing = false

func handle_wire_action():
	var collider = wire_ray.get_collider()
	if collider:
		# Handle: Click wirable obj
		if is_instance_valid(powerline):
			# Handle: Click wirable obj while holding a wire
			if collider == powerline.pair[0]:
				# Handle: Click on the same obj that gave us the wire we're holding
				powerline.destroy()
				print("Cannot connect to self, clearing")
				return true
			else: 
				# Handle: Click on something wirable, but different than what we're holding
				powerline.end(wire_ray)
				powerline = null
				wire_place_audio.play(0.0)
				return true
		else:
			# Handle: Click wirable area, but we aren't holding a wire
			powerline = PowerLineScene.instance()
			powerline.set_interact(self)
			powerline.begin(wire_ray)
			wire_place_audio.play(0.0)
			return true
	else:
		# Handle: Clicked, but not on something wirable
		if is_instance_valid(powerline):
			powerline.destroy()
			print("Invalid end-point, clearing.")
			return true
	return false

func handle_held_object(delta):
	if is_instance_valid(held_object):
		var pos = held_object.global_transform.origin
		var to = player.global_transform.origin + Vector3(0,1,0)
		var distance = pos.distance_to(to)
		var direction = pos.direction_to(to)
		var thrust_vector = (direction * (distance * 50)) * delta
		#held_object.global_transform.origin.y = to.y + 1
		held_object.apply_central_impulse(thrust_vector)
func handle_pickup_action():
	var collider = pickup_ray.get_collider()
	
	if is_instance_valid(held_object):
		# dereference to drop object
		#held_object.mode = held_object.MODE_RIGID
		#if held_object.is_connected("force", self, "handle_held_object"):
		#	held_object.disconnect("force", self, "handle_held_object")
		held_object = null
		return true
	elif collider:
		print("should pick something up")
		print(collider)
		held_object = collider
		#held_object.connect("force", self, "handle_held_object")
		#held_object.mode = held_object.MODE_STATIC
		return true
	
	return false

func handle_clip_action():
	var collider = clip_ray.get_collider()
	if collider:
		if is_instance_valid(collider) and is_instance_valid(collider.get_parent()):
			if collider.get_parent().has_method("disconnect_pair"):
				collider.get_parent().disconnect_pair()
				return true
		else:
			print("can't clip this..")
			print(collider)
	return false
			
