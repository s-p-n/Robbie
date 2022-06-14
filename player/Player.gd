extends KinematicBody

onready var tool_menu = $Head/ToolMenu
onready var tool_label = $Head/ToolPanel/ToolLabel
var wire_hold_node = preload("res://Scenes/wires/WirePosition.tscn")


var wire_held = false
var mouse_sensitivity = 1
var joystick_deadzone = 0.2

# Movement
var run_speed = 6 # Running speed in m/s
# Walk speed is actually run. Because peter said so.
var walk_speed = run_speed * 2
var crouch_speed = run_speed / 3
var jump_height = 4
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

# COLLISION LAYERS FOR EACH ITEM
# Claw   = 4   Wire  = 6
# Solder = 7   Brush = 5
enum hand {CLAW, WIRE, SOLDER, BRUSH}
var tool_state = hand.CLAW
var mouse_visible

var held_object = null

# Data:
var player_speed = 0
var falling_velocity = 0
onready	var start_pos = $Head/Camera/PositionStart
onready	var stop_pos = $Head/Camera/PositionStop
onready var pickup_ray = $Head/PickupRay
onready var brush_ray = $Head/BrushRay
onready var wire_ray = $Head/WireRay
onready var wire_position = $WirePosition
onready var wires
var offset = Vector3(0, 1.6, 0)

# Shooting
onready var marker = preload("res://scenes/marker.tscn")
onready var wire = preload("res://scenes/Wire.tscn")

func _ready():
	wires = get_parent().find_node('Wires')
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
	if wire_held:
		wires.get_child(wires.get_child_count() - 1).stop_position.global_transform.origin = wire_position.global_transform.origin
	if held_object:
		held_object.global_transform.origin = stop_pos.global_transform.origin	
	
	if Input.is_action_just_pressed("tilda"):
		if held_object:
			pass
		else:
			if mouse_visible:
				#print(mouse_visible)
				mouse_visible = false
				tool_menu.visible = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				#print(mouse_visible)
				mouse_visible = true
				tool_menu.visible = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if mouse_visible:
		return
	process_movement(delta)
	if Input.is_action_just_pressed("leftclick"):
		var current_position = translation
		#print("Drawing Intersect Line.\nFrom: ", start_pos.global_transform.origin, "\nTo ", stop_pos.global_transform.origin)
		var space = get_viewport().world.direct_space_state
		var results = space.intersect_ray(start_pos.global_transform.origin, stop_pos.global_transform.origin, [self])
		
		# Checks for collision data
		if results:
			#print(results)
			pass
			

		# Picks up object if claw is equipped and there is an object in the collider	
		if tool_state == hand.CLAW:
			if held_object:
				#print("Dropping Held Object")
				#held_object.mode = RigidBody.MODE_RIGID
				held_object.set_linear_velocity(Vector3(0,-0.1,0))
				held_object = null
			else:
				print(pickup_ray.get_collider())
				if pickup_ray.get_collider():
					#print("Picking up object")
					held_object = pickup_ray.get_collider()
					#held_object.mode = RigidBody.MODE_KINEMATIC
		
		if tool_state == hand.BRUSH:
			var dirty_object = brush_ray.get_collider()
			print("attempt to clean")
			print(dirty_object)
			if dirty_object:
				dirty_object.clean()
				if dirty_object.get_health() > 0:
					dirty_object.spawn_particle(brush_ray.get_collision_point())
					print(brush_ray.get_collision_point())
		
		if tool_state == hand.WIRE:
			if wire_ray.get_collider():
				print(wire_ray.get_collider())
				if wire_held:
					print("Placing end of wire")
					# Set wire end point.
					var wire_index = wires.get_child_count() - 1
					wires.get_child(wire_index).stop_position.global_transform.origin = wire_ray.get_collision_point()
					wire_held = false
				else:
					var wire_index = wires.get_child_count()
					# Set position of wire to new child node on pylon
					print("Placing start of wire.")
					# Spawn wire`
					var new_wire = wire.instance()
					var wire_start_pos = wire_hold_node.instance()
					wire_start_pos.index_id = wire_index
					wire_ray.get_collider().points.add_child(wire_start_pos)
					
					wire_start_pos.name = 'WirePositionStart'
					print(wire_ray.get_collision_point(), ' ', wire_start_pos.global_transform.origin)
					wire_start_pos.global_transform.origin = wire_ray.get_collision_point()
					print(wire_ray.get_collision_point(), ' ', wire_start_pos.global_transform.origin)
					new_wire.set_translation(wire_start_pos.global_transform.origin)
					wires.add_child(new_wire)
					wire_held = true
					new_wire.visible = true
					print(wires.get_child_count())
					

func set_tool(tool_name):
	if tool_name.to_lower() == 'claw':
		tool_state = hand.CLAW
		tool_label.text = 'Claw'
	elif tool_name.to_lower() == 'brush':
		tool_state = hand.BRUSH
		tool_label.text = 'Brush'
	elif tool_name.to_lower() == 'solder':
		tool_state = hand.SOLDER
		tool_label.text = 'Solder'
	elif tool_name.to_lower() == 'wire':
		tool_state = hand.WIRE
		tool_label.text = 'Wire'
	print("Tool State: ", tool_state)

func process_movement(delta):
	# Look with the right analog of the joystick
	if Input.get_joy_axis(0, 2) < -joystick_deadzone or Input.get_joy_axis(0, 2) > joystick_deadzone:
		rotation_degrees.y -= Input.get_joy_axis(0, 2) * 2
	if Input.get_joy_axis(0, 3) < -joystick_deadzone or Input.get_joy_axis(0, 3) > joystick_deadzone:
		$Head.rotation_degrees.x = clamp($Head.rotation_degrees.x - Input.get_joy_axis(0, 3) * 2, -90, 90)
	
	# Direction inputs
	direction = Vector3()
	
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_UP):
		direction.z += -1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.z += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_LEFT):
		direction.x += -1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
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

func _on_BrushButton_button_down():
	set_tool('brush')

func _on_SolderButton_button_down():
	set_tool('solder')
	
func get_wire_position():
	return wire_position.global_transform.origin
	
func delete_held_wire():
	var wire_index = wires.get_child_count() - 1
	wires.get_child(wire_index).queue_free()
	wire_held = false
	print("Wire is snagged. Try again.")
	
