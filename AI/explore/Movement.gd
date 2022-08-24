extends Spatial

signal stuck

var brain

var snapped = false
var ground_acceleration = 10
var air_acceleration = 5
var acceleration = air_acceleration
var falling_velocity = 0
var jump_height = 10

var forward_command = true
var rotate_command = true
var jump_command = false

var gravity = 9.8
var gravity_vec:Vector3
var destination:Vector3
var velocity = Vector3() # Direction with acceleration added
var movement = Vector3() # Velocity with gravity added
var last_pos = Vector3()

var direction_favor:int = 1

var cleanup_time = 1
var time = 0
func _ready():
	direction_favor = int(round(randf()))
	if direction_favor == 0:
		direction_favor = -1
	#print("Direction favor set: ", direction_favor)
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
		
		#print(round(rand_range(0, 1)))
		if randf() < 0.05:
			direction_favor = int(round(randf()))
			if direction_favor == 0:
				direction_favor = -1
			#print("Direction favor possibly changed: ", direction_favor)
		
		var change = rand_range(10,45) * direction_favor
		mob.rotation_degrees.y = lerp(rot_y, rot_y + change, delta * 5)
		rotate_command = false
		forward_command = false
		
	#if forward_command:
	var direction = Vector3.ZERO
	if can_jump() and is_on_floor():
		jump_command = true
	elif obstacle_is_ahead() and is_on_floor():
		rotate_command = true
	elif !obstacle_is_ahead():
		if ground_is_ahead() or !is_on_floor():
			direction = mob.global_transform.basis.x
		elif is_on_floor():
			rotate_command = true
	move(direction, delta)

func is_on_floor():
	return is_instance_valid(brain.ground_ray.get_collider())
	
func obstacle_is_ahead():
	return is_instance_valid(brain.ahead_ray.get_collider())

func ground_is_ahead():
	return is_instance_valid(brain.ground_ahead_ray.get_collider())

func can_jump():
	var object_ahead = brain.ahead_ray.get_collider()
	var object_beneath = brain.ground_ray.get_collider()
	if !is_instance_valid(object_ahead) or !is_instance_valid(object_beneath):
		return false
	
	if object_ahead == object_beneath:
		return false
	
	return !is_instance_valid(brain.jump_ray.get_collider())

func handle_follow(entity:Spatial, delta):
	if !is_instance_valid(brain):
		get_brain()
		return

	var mob:KinematicBody = brain.get_parent()
	
	if !is_instance_valid(mob):
		return
	
	if !is_instance_valid(entity):
		move(Vector3(0,0,0), delta)
		return
		
	var entity_origin = entity.global_transform.origin
	
	if entity.name == 'WireWhole':
		var a = entity.powerline.pair[0].global_transform.origin
		var b = entity.powerline.pair[1].global_transform.origin
		entity_origin = (a + b) / 2
	
	var look_at = entity_origin# + Vector3(0,0.25,0)
	look_at.y = mob.global_transform.origin.y
	if !look_at.is_equal_approx(mob.global_transform.origin):
		mob.global_transform = mob.global_transform.looking_at(look_at, Vector3.UP)
		mob.rotation_degrees.y += 90
	
	#print(mob.rotation_degrees)
	
	#mob.transform = mob.transform.orthonormalized()
	
	var my_origin = mob.global_transform.origin
	var direction = my_origin.direction_to(entity_origin)
	
	if (my_origin.y + 0.5) < entity_origin.y:
		jump_command = true
	else:
		jump_command = false
	
	move(direction, delta)

func move(direction, delta):
	var mob:KinematicBody = brain.get_parent()
	brain.ahead_ray.rotation_degrees.x += 10
	
	if direction.is_equal_approx(Vector3.ZERO):
		get_parent().get_node("Sounds/Walking").stop_stream()
	else:
		get_parent().get_node("Sounds/Walking").play_stream()
	
	if is_on_floor():
		acceleration = ground_acceleration
		gravity_vec = -mob.get_floor_normal() * 10
		gravity_vec.y = 0
		if !snapped:
			snapped = true
			#print("land")
			get_parent().get_node("Sounds/Land").play(0)
	else:
		acceleration = air_acceleration
		if snapped:
			gravity_vec = Vector3()
			snapped = false
		else:
			gravity_vec += Vector3.DOWN * gravity * delta
	
	if jump_command:
		if is_on_floor():
			#print("jump!")
			get_parent().get_node("Sounds/Jump").play(0)
			snapped = false
			jump_command = false
			gravity_vec = Vector3.UP * jump_height
	
	# "bug" where entities can climb on ceiling:
	# Also prevents entities from going through ceiling
	if mob.is_on_ceiling():
		velocity.y = 0
	
	velocity = velocity.linear_interpolate(direction * brain.speed, acceleration * delta)
	
	
	movement.x = velocity.x + gravity_vec.x
	movement.z = velocity.z + gravity_vec.z
	movement.y = gravity_vec.y
	
	if Vector3.ZERO.is_equal_approx(movement * Vector3(1,0,1)):
		emit_signal("stuck")
	
	movement = mob.move_and_slide(movement, Vector3.UP)
	handle_cleanup(delta)

func handle_cleanup(delta):
	time += delta
	if time > cleanup_time:
		var mob = brain.get_parent()
		time = 0
		mob.global_transform = mob.global_transform.orthonormalized()
		
