extends Spatial

signal move_on_floor()

onready var footstep_scene = $FootstepSound
onready var landTween:Tween = $LandTween
var head:Position3D
var camera:Camera

var mouse_sensitivity = 1
var joystick_deadzone = 0.2

# Movement
var is_moving = false
var run_speed = 8 # Running speed in m/s
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
var player_speed = 0
var falling_velocity = 0
var is_setup = false
var player:KinematicBody

func _ready():
	set_player(find_parent("Player"))

func set_player(new_player):
	player = new_player
	head = player.find_node("Head")
	camera = player.find_node("Camera")
	footstep_scene.set_movement(self)

func _unhandled_input(event):
	# Look with the mouse
	if (event is InputEventMouseMotion):
		player.rotation_degrees.y -= event.relative.x * mouse_sensitivity / 18
		head.rotation_degrees.x -= event.relative.y * mouse_sensitivity / 18
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 90)

func _physics_process(delta):
	var moved = false
	# Look with the right analog of the joystick
	if Input.get_joy_axis(0, 2) < -joystick_deadzone or Input.get_joy_axis(0, 2) > joystick_deadzone:
		player.rotation_degrees.y -= Input.get_joy_axis(0, 2) * 2
	if Input.get_joy_axis(0, 3) < -joystick_deadzone or Input.get_joy_axis(0, 3) > joystick_deadzone:
		head.rotation_degrees.x = clamp(head.rotation_degrees.x - Input.get_joy_axis(0, 3) * 2, -90, 90)
	
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
	direction = direction.rotated(Vector3.UP, player.rotation.y)
	
	# Snaps the character on the ground and changes the gravity vector to climb
	# slopes at the same speed until 45 degrees
	if player.is_on_floor():
		if snapped == false:
			falling_velocity = gravity_vec.y
			land_animation()
		acceleration = ground_acceleration
		movement.y = 0
		gravity_vec = -player.get_floor_normal() * 10
		snapped = true
	else:
		moved = true
		acceleration = air_acceleration
		if snapped:
			gravity_vec = Vector3()
			snapped = false
		else:
			gravity_vec += Vector3.DOWN * gravity * delta
	
	if player.is_on_floor():
		if Input.is_key_pressed(KEY_SHIFT) or Input.get_joy_axis(0, 6) >= 0.6:
			current_speed = walk_speed
		else:
			current_speed = run_speed
		if crouched:
			current_speed = crouch_speed
	
	if Input.is_key_pressed(KEY_SPACE) or Input.is_joy_button_pressed(0, JOY_XBOX_A):
		if player.is_on_floor() and can_jump:
			moved = true
			snapped = false
			can_jump = false
			gravity_vec = Vector3.UP * jump_height
	else:
		can_jump = true
	
	# "bug" where player can climb on ceiling:
	if player.is_on_ceiling():
		velocity.y = 0
	
	velocity = velocity.linear_interpolate(direction * current_speed, acceleration * delta)
	
	movement.x = velocity.x + gravity_vec.x
	movement.z = velocity.z + gravity_vec.z
	movement.y = gravity_vec.y
	
	movement = player.move_and_slide(movement, Vector3.UP)
	
	player_speed = movement.length()
	
	if moved:
		is_moving = true
	else:
		is_moving = false
	
	if is_moving and player.is_on_floor() and player_speed >= 2:
		emit_signal("move_on_floor")

func land_animation():
	var movement_y = clamp(falling_velocity, -20, 0) / 40
	
	if !landTween.interpolate_property(camera, "translation:y", 0, movement_y, 0.1, Tween.TRANS_SINE, Tween.EASE_OUT):
		# Could handle error-case
		pass
	
	if !landTween.interpolate_property(camera, "translation:y", movement_y, 0, 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.1):
		# Could handle error-case
		pass
	
	if !landTween.start():
		# Could handle error-case
		pass
