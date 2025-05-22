extends KinematicBody

export var menu_wait_time:float = 0.25
onready var tool_menu = $Head/ToolMenu
onready var tool_label = $Head/ToolPanel/ToolLabel
onready var pause_screen = get_tree().root.find_node("Paused")
onready var wire_reel_audio = $Sounds/WireReelAudio
onready var placement_audio = $Sounds/PlacementAudio
onready var clip_wire_audio = $Sounds/WireCutAudio
var wire_hold_node = preload("res://Scenes/wires/WirePosition.tscn")

const wire_max_health = 3
var wire_health = wire_max_health

var wire_held = false
var mouse_sensitivity = 1
var joystick_deadzone = 0.2
var looking_at_interactable = false
# Movement
var is_moving = false
var run_speed = 8 # Running speed in m/s
# Walk speed is actually run. Because peter said so.
var walk_speed = run_speed * 2
var crouch_speed = run_speed / 3
var jump_height = 6
var current_speed = run_speed
var ground_acceleration = 10
var air_acceleration = 5
var acceleration = air_acceleration
var direction = Vector3()
var velocity = Vector3() # Direction with acceleration added
var movement = Vector3() # Velocity with gravity added
var gravity = 9.8
var gravity_vec = Vector3()
var snapped = false
var can_jump = true
var crouched = false
var can_crouch = true
var bad_position = false
export var update_pos_time = .5

# COLLISION LAYERS FOR EACH ITEM
# Claw   = 4   Wire  = 6
# Solder = 7   Vacuum = 5
enum hand {CLAW, WIRE, SOLDER, VACUUM}
var tool_state = hand.CLAW
var mouse_visible

var held_object = null

# Data:
var player_speed = 0
var falling_velocity = 0
onready	var start_pos = $Head/Camera/PositionStart
onready	var stop_pos = $Head/Camera/PositionStop
onready var pickup_ray = $Head/PickupRay
onready var vacuum_ray = $Head/VacuumRay
onready var wire_ray = $Head/WireRay
onready var solder_ray = $Head/SolderRay
onready var wire_position = $WirePosition
onready var wires
onready var interactable_notice = $Head/CenterDot/Interactable
var offset = Vector3(0, 1.6, 0)
var pos_time = 0.0
var last_valid_pos: Vector3

var time_since_mouse_down:float = 0.0
# Shooting
onready var marker = preload("res://Scenes/marker.tscn")
onready var wire = preload("res://Scenes/Wire.tscn")

func _ready():
	last_valid_pos = global_transform.origin
	wire_held = false
	wires = get_tree().current_scene.find_node('Wires')
	tool_label.text = 'Claw'
	tool_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_visible = false

func _input(event):
	# Look with the mouse
	if (event is InputEventMouseMotion) and (mouse_visible == false):
		rotation_degrees.y -= event.relative.x * mouse_sensitivity / 18
		$Head.rotation_degrees.x -= event.relative.y * mouse_sensitivity / 18
		$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x, -90, 90)
		
	direction = Vector3()

func _physics_process(delta):
	var interactables = look_for_interactables()
	if !tool_menu.visible and Input.is_mouse_button_pressed(BUTTON_LEFT):
		if time_since_mouse_down >= menu_wait_time:
			time_since_mouse_down = 0
			show_tool_menu()
		time_since_mouse_down += delta
	if wire_held:
		wires.get_child(wires.get_child_count() - 1).stop_position.global_transform.origin = wire_position.global_transform.origin
	
	if held_object:
		held_object.global_transform.origin = stop_pos.global_transform.origin	
	
	setup_interactable_notice(interactables)
	handle_tool_menu()
	
	if false and Input.is_action_just_pressed("tilda"):
		if held_object or wire_held:
			pass
		else:
			if mouse_visible:
				mouse_visible = false
				pause_screen.visible = false
				find_parent("Robbie").is_paused = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				mouse_visible = true
				pause_screen.visible = true
				find_parent("Robbie").is_paused = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	if tool_menu.visible or mouse_visible:
		if not Input.is_action_just_released("leftclick"):
			return
	
	pos_time += delta
	process_movement(delta)
	if wires.get_child_count() > 0:
		var held_wire_node = wires.get_child(wires.get_child_count() - 1)
		if held_wire_node and held_wire_node.is_colliding and wire_held:
			bad_position = true
		else:
			bad_position = false
	if (pos_time >= update_pos_time) and !bad_position:
		if (global_transform.origin.distance_to(last_valid_pos) > 4.5):
			pos_time = 0.0
			last_valid_pos = global_transform.origin
	if bad_position:
		global_transform.origin = last_valid_pos
	
	if is_moving and wire_held:
		if not wire_reel_audio.playing:
			wire_reel_audio.playing = true
	else:
		wire_reel_audio.playing = false
	if Input.is_action_just_pressed("leftclick"):
		time_since_mouse_down = 0.0
		#if looking_at_interactable:
		#	show_tool_menu()
		
	if Input.is_action_just_released("leftclick"):
		hide_tool_menu()

		# Picks up object if claw is equipped and there is an object in the collider	
		if tool_state == hand.CLAW:
			if held_object:
				held_object.set_linear_velocity(Vector3(0,-0.1,0))
				held_object = null
			else:
				if pickup_ray.get_collider():
					held_object = pickup_ray.get_collider()
		
		elif tool_state == hand.VACUUM:
			var dirty_object = vacuum_ray.get_collider()
			if dirty_object and dirty_object.has_method("clean"):
				dirty_object.clean()
				if dirty_object.get_health() > 0:
					dirty_object.spawn_particle(vacuum_ray.get_collision_point())
		
		elif tool_state == hand.WIRE:
			if wire_ray.get_collider():
				if wire_held:
					# Set wire end point.
					var wire_index = wires.get_child_count() - 1
					var wire_end_pos = wire_hold_node.instance()
					wire_end_pos.index_id = wire_index
					wire_ray.get_collider().get_parent().get_parent().end_points.add_child(wire_end_pos)
					wire_end_pos.name = 'WirePositionEnd'
					wire_end_pos.global_transform.origin = wire_ray.get_collision_point()
					wire_end_pos.transform.origin.x = 0
					wire_end_pos.transform.origin.z = 0
					wires.get_child(wire_index).stop_position.global_transform.origin = wire_end_pos.global_transform.origin
					placement_audio.play()
					wire_held = false
				else:
					var wire_index = wires.get_child_count()
					# Set position of wire to new child node on pylon
					
					# Spawn wire
					var new_wire = wire.instance()
					var wire_start_pos = wire_hold_node.instance()
					wire_start_pos.index_id = wire_index
					wire_ray.get_collider().get_parent().get_parent().start_points.add_child(wire_start_pos)
					wire_start_pos.name = 'WirePositionStart'
					wire_start_pos.global_transform.origin = wire_ray.get_collision_point()
					wire_start_pos.transform.origin.x = 0
					wire_start_pos.transform.origin.z = 0
					new_wire.set_translation(wire_start_pos.global_transform.origin)
					wires.add_child(new_wire)
					wire_held = true
					new_wire.visible = true
					placement_audio.play()
		elif tool_state == hand.SOLDER:
			var solderable_object = solder_ray.get_collider()
			if solderable_object and solderable_object.has_method("solder"):
				solderable_object.solder()
				if solderable_object.damage > 0:
					solderable_object.spawn_particle(vacuum_ray.get_collision_point())

func show_tool_menu():
	#mouse_visible = true
	tool_menu.visible = true
	tool_label.get_parent().visible = true
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_tool_menu():
	#mouse_visible = false
	tool_menu.visible = false
	#tool_label.get_parent().visible = false
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func handle_tool_menu():
	if tool_menu.visible:
		if Input.is_action_just_released("up"):
			set_tool("claw")
			hide_tool_menu()
		elif Input.is_action_just_released("right"):
			set_tool("solder")
			hide_tool_menu()
		elif Input.is_action_just_released("down"):
			set_tool("vacuum")
			hide_tool_menu()
		elif Input.is_action_just_released("left"):
			set_tool("wire")
			hide_tool_menu()
		
		
func look_for_interactables():
	return [
		pickup_ray.get_collider(),
		wire_ray.get_collider(),
		solder_ray.get_collider(),
		vacuum_ray.get_collider()
	]
	
func setup_interactable_notice(interactables):
	# interactalbes is expected to be an array of Nodes or Nil/falsey nodes
	# using `!interactables[0]` will return True for null nodes, so we have to 
	# use 2, such as `!!interactables[0]` to get False for null nodes, and True
	# for nodes that we can interact with. Tada! we know if we can interact.
	var can_grab = !!interactables[0]
	var can_wire = !!interactables[1]
	var can_solder = !!interactables[2]
	var can_vacuum = !!interactables[3]
	
	var interacting = held_object
	if (not interacting) and (can_grab or can_wire or can_solder or can_vacuum):
		looking_at_interactable = true
		interactable_notice.visible = true
	else:
		looking_at_interactable = false
		interactable_notice.visible = false
	
func set_tool(tool_name):
	if tool_name.to_lower() == 'claw':
		tool_state = hand.CLAW
		tool_label.text = 'Claw'
	elif tool_name.to_lower() == 'vacuum':
		tool_state = hand.VACUUM
		tool_label.text = 'Vacuum'
	elif tool_name.to_lower() == 'solder':
		tool_state = hand.SOLDER
		tool_label.text = 'Solder'
	elif tool_name.to_lower() == 'wire':
		tool_state = hand.WIRE
		tool_label.text = 'Wire'

func process_movement(delta):
	var moved = false
	# Look with the right analog of the joystick
	if Input.get_joy_axis(0, 2) < -joystick_deadzone or Input.get_joy_axis(0, 2) > joystick_deadzone:
		rotation_degrees.y -= Input.get_joy_axis(0, 2) * 2
	if Input.get_joy_axis(0, 3) < -joystick_deadzone or Input.get_joy_axis(0, 3) > joystick_deadzone:
		$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x - Input.get_joy_axis(0, 3) * 2, -90, 90)
	
	# Direction inputs
	direction = Vector3()
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_UP):
		moved = true
		direction.z += -1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		moved = true
		direction.z += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_LEFT):
		moved = true
		direction.x += -1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		moved = true
		direction.x += 1
		
	direction = direction.normalized()
	
	#If we aren't using the keyboard, take the input from the left analog of the joystick
	if direction == Vector3():
		direction.z = Input.get_joy_axis(0, 1)
		direction.x = Input.get_joy_axis(0, 0)
		
		# Apply a deadzone to the joystick
		if direction.z < joystick_deadzone and direction.z > -joystick_deadzone:
			direction.z = 0
		if direction.x < joystick_deadzone and direction.x > -joystick_deadzone:
			direction.x = 0
	
	# Rotates the direction from the Y axis to move forward
	direction = direction.rotated(Vector3.UP, rotation.y)
	
	# Snaps the character on the ground and changes the gravity vector to climb
	# slopes at the same speed until 45 degrees
	if is_on_floor():
		if snapped == false:
			falling_velocity = gravity_vec.y
			land_animation()
		acceleration = ground_acceleration
		movement.y = 0
		gravity_vec = -get_floor_normal() * 10
		snapped = true
	else:
		moved = true
		acceleration = air_acceleration
		if snapped:
			gravity_vec = Vector3()
			snapped = false
		else:
			gravity_vec += Vector3.DOWN * gravity * delta
	
	if is_on_floor():
		if Input.is_key_pressed(KEY_SHIFT) or Input.get_joy_axis(0, 6) >= 0.6:
			current_speed = walk_speed
		else:
			current_speed = run_speed
		if crouched:
			current_speed = crouch_speed
	
	if Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_XBOX_A):
		if is_on_floor() and can_jump:
			moved = true
			snapped = false
			can_jump = false
			gravity_vec = Vector3.UP * jump_height
	else:
		can_jump = true
	
	if is_on_ceiling():
		gravity_vec.y = 0
	
	if Input.is_key_pressed(KEY_CONTROL) or Input.is_key_pressed(KEY_C) or Input.is_joy_button_pressed(0, JOY_XBOX_B):
		crouch_animation(true)
	else:
		crouch_animation(false)
	
	velocity = velocity.linear_interpolate(direction * current_speed, acceleration * delta)
	
	movement.x = velocity.x + gravity_vec.x
	movement.z = velocity.z + gravity_vec.z
	movement.y = gravity_vec.y
	
	movement = move_and_slide(movement, Vector3.UP)
	
	player_speed = movement.length()
	if moved:
		is_moving = true
	else:
		is_moving = false

func land_animation():
	var movement_y = clamp(falling_velocity, -20, 0) / 40
	
	$LandTween.interpolate_property($Head/Camera, "translation:y", 0, movement_y, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT)
	$LandTween.interpolate_property($Head/Camera, "translation:y", movement_y, 0, 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1)
	$LandTween.start()

func crouch_animation(button_pressed):
	if button_pressed:
		if not crouched:
			$CrouchTween.interpolate_property($MeshInstance, "mesh:mid_height", $MeshInstance.mesh.mid_height, 0.25, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CrouchTween.interpolate_property($CollisionShape, "shape:height", $CollisionShape.shape.height, 0.25, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CrouchTween.interpolate_property($Head, "translation:y", $Head.translation.y, 1.35, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CrouchTween.start()
			crouched = true
	else:
		if crouched:
			$CrouchTween.interpolate_property($MeshInstance, "mesh:mid_height", $MeshInstance.mesh.mid_height, 0.75, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CrouchTween.interpolate_property($CollisionShape, "shape:height", $CollisionShape.shape.height, 0.75, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CrouchTween.interpolate_property($Head, "translation:y", $Head.translation.y, 1.6, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$CrouchTween.start()
			crouched = false


func _on_ClawButton_button_down():
	set_tool('claw')

func _on_WireButton_button_down():
	set_tool('wire')

func _on_VacuumButton_button_down():
	set_tool('vacuum')

func _on_SolderButton_button_down():
	set_tool('solder')
	
func get_wire_position():
	return wire_position.global_transform.origin
	
func delete_wire(wire_id):
	clip_wire_audio.play(0)
	wires.get_child(wire_id).visible = false
		
func delete_held_wire():
	print("wire hp: ", wire_health)
	wire_health -= 1
	if wire_health <= 0:
		wire_health = wire_max_health
		var wire_index = wires.get_child_count() - 1
		var wire_end_pos = wire_hold_node.instance()
		var wire = wires.get_child(wire_index)
		wire_end_pos.index_id = wire_index
		wire_end_pos.global_transform.origin = global_transform.origin
		wire_end_pos.transform.origin.x = 0
		wire_end_pos.transform.origin.z = 0
		wire.stop_position.global_transform.origin = wire_end_pos.global_transform.origin
		wire_held = false
		clip_wire_audio.play(0)
		wire.visible = false
	else:
		velocity.x = 0
		velocity.z = 0
