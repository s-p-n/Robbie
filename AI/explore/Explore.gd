extends Spatial

signal discovery(entity)
signal see(entity)
signal stand_on(entity)
#signal obstacle_ahead(entity)
#signal no_path_ahead()


onready var brain:Spatial = get_parent()
onready var decide:Spatial = brain.get_node("Decide")
onready var react:Spatial = brain.get_node("React")
onready var movement:Spatial = get_node("Movement")

var player = null

var discovered_objects = []
var follow_entity:Spatial

var time_since_saw_follow_entity:float = 0
var follow_until:float = 5

var state

enum State {
	EXPLORE,
	FOLLOW,
}
func _ready():
	state = State.EXPLORE
	get_player()
	if OK != movement.connect("stuck", self, "_handle_stuck"):
		pass

func get_player():
	var objects = find_parent("Objects")
	if is_instance_valid(objects):
		player = objects.find_node("Player")

func _process(delta):
	if !is_instance_valid(player):
		get_player()
		return
	#if global_transform.origin.distance_to(player.global_transform.origin) < 50:
	discover()
	something_beneath(brain.ground_ray.get_collider())
	process_current_state(delta)

func _handle_stuck():
	if state == State.FOLLOW:
		state = State.EXPLORE
		movement.jump_command = true
		movement.rotate_command = true
		follow_entity = null
	

func process_current_state(delta):
	match state:
		State.EXPLORE:
			movement.handle_explore(delta)
		State.FOLLOW:
			time_since_saw_follow_entity += delta
			if time_since_saw_follow_entity < follow_until:
				movement.handle_follow(follow_entity, delta)
			else:
				state = State.EXPLORE
				follow_entity = null
func something_beneath(entity):
	if is_instance_valid(entity):
		emit_signal("stand_on", entity)

func discover():
	var rays = brain.vision.get_children()
	for ray in rays:
		if ray == brain.ground_ray:
			continue
		var entity = ray.get_collider()
		if is_instance_valid(entity):
			if not (entity in discovered_objects):
				discovered_objects.append(entity)
				emit_signal("discovery", entity, ray.get_collision_point())
			emit_signal("see", entity, ray.get_collision_point())


func move_towards(point:Vector3):
	if !is_moving():
		movement.destination = point

func move_forward():
	movement.forward_command = true

func follow(target:Spatial):
	if !is_instance_valid(follow_entity):
		follow_entity = null
	
	if !is_instance_valid(target):
		return
	
	if follow_entity != null and follow_entity != target:
		var length = len(brain.seek_out_object_names)
		var cur_weight = length - brain.seek_out_object_names.find(follow_entity.name)
		var new_weight = length - brain.seek_out_object_names.find(target.name)
		
		if new_weight >= cur_weight:
			follow_entity = target
	else:
		follow_entity = target
	if follow_entity.name == "Player" or follow_entity.name == "WaterBlob":
		time_since_saw_follow_entity = 0
	state = State.FOLLOW

func turn():
	movement.rotate_command = true

func is_moving():
	if !is_instance_valid(brain):
		return false
	
	var mob = brain.get_parent()
	
	if !is_instance_valid(mob):
		return false
	
	var my_pos:Vector3 = mob.global_transform.origin
	
	return not react.within_range(my_pos.distance_to(movement.destination))


