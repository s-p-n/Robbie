extends Spatial

var brain

var snapped = false
var can_jump = false
var ground_acceleration = 10
var air_acceleration = 5
var acceleration = air_acceleration
var falling_velocity = 0
var jump_height = 6

var forward_command = true
var rotate_command = true
var jump_command = false

var gravity = 9.8
var gravity_vec:Vector3
var destination:Vector3
var velocity = Vector3() # Direction with acceleration added
var movement = Vector3() # Velocity with gravity added
var last_pos = Vector3()

var cleanup_time = 1
var time = 0

func get_brain():
	brain = get_parent().brain
	ground_acceleration = brain.speed
	air_acceleration = ground_acceleration / 2

func handle_explore(delta):
	if !is_instance_valid(brain):
		get_brain()
		return

	var mob:KinematicBody = brain.get_parent()
	
	if !is_instance_valid(mob):
		return
	
	var rot_y = mob.rotation_degrees.y
	
	if rotate_command:
		var r = round(rand_range(-1, 1))
		if r == 0:
			r = 1
		
		var change = 50 * r
		mob.rotation_degrees.y = lerp(rot_y, rot_y + change, delta * 50)
		rotate_command = false
		forward_command = false
		
	#if forward_command:
	var direction = Vector3.ZERO
	if can_jump and mob.is_on_floor() and obstacle_is_ahead():
		jump_command = true
	else:
		direction = mob.global_transform.basis.x
	move(direction, delta)

func is_on_floor():
	return is_instance_valid(brain.ground_ray.get_collider())
	
func obstacle_is_ahead():
	return is_instance_valid(brain.ahead_ray.get_collider())

func handle_follow(entity:Spatial, delta):
	if !is_instance_valid(brain):
		get_brain()
		return

	var mob:KinematicBody = brain.get_parent()
	
	if !is_instance_valid(mob):
		return
	
	var look_at = entity.global_transform.origin# + Vector3(0,0.25,0)
	look_at.y = mob.global_transform.origin.y
	mob.global_transform = mob.global_transform.looking_at(look_at, Vector3.UP)
	mob.rotation_degrees.y += 90
	
	#print(mob.rotation_degrees)
	
	#mob.transform = mob.transform.orthonormalized()
	
	var my_origin = mob.global_transform.origin
	var entity_origin = entity.global_transform.origin
	var direction = my_origin.direction_to(entity_origin)
	
	if (my_origin.y + 0.5) < entity_origin.y:
		jump_command = true
	else:
		jump_command = false
	
	move(direction, delta)

func move(direction, delta):
	var mob:KinematicBody = brain.get_parent()
	
	if mob.is_on_floor():
		acceleration = ground_acceleration
		gravity_vec = -mob.get_floor_normal() * 10
		gravity_vec.y = 0
		snapped = true
	else:
		acceleration = air_acceleration
		if snapped:
			gravity_vec = Vector3()
			snapped = false
		else:
			gravity_vec += Vector3.DOWN * gravity * delta
	
	if mob.is_on_floor():
		can_jump = true
	
	if jump_command:
		if mob.is_on_floor() and can_jump:
			#print("jump!")
			snapped = false
			can_jump = false
			jump_command = false
			gravity_vec = Vector3.UP * jump_height
	
	
	
	# "bug" where entities can climb on ceiling:
	if mob.is_on_ceiling():
		velocity.y = 0
	
	velocity = velocity.linear_interpolate(direction * brain.speed, acceleration * delta)
	
	movement.x = velocity.x + gravity_vec.x
	movement.z = velocity.z + gravity_vec.z
	movement.y = gravity_vec.y
	
	movement = mob.move_and_slide(movement, Vector3.UP)
	handle_cleanup(delta)

func handle_cleanup(delta):
	time += delta
	if time > cleanup_time:
		var mob = brain.get_parent()
		time = 0
		mob.global_transform = mob.global_transform.orthonormalized()
		
