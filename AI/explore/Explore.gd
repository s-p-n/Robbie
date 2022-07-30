extends Spatial

signal discovery(entity)

signal see(entity)
signal stand_on(entity)
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

func get_player():
	var objects = find_parent("Objects")
	if is_instance_valid(objects):
		player = objects.find_node("Player")

func _process(delta):
	if !is_instance_valid(player):
		get_player()
		return
	if global_transform.origin.distance_to(player.global_transform.origin) < 50:
		discover(brain.ahead_ray.get_collider())
		something_beneath(brain.ground_ray.get_collider())
		process_current_state(delta)
	

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
func something_beneath(entity):
	if is_instance_valid(entity):
		emit_signal("stand_on", entity)

func discover(entity):
	if is_instance_valid(entity):
		if not (entity in discovered_objects):
			discovered_objects.append(entity)
			emit_signal("discovery", entity)
		emit_signal("see", entity)


func move_towards(point:Vector3):
	if !is_moving():
		movement.destination = point

func move_forward():
	movement.forward_command = true

func follow(target:Spatial):
	if state != State.FOLLOW and target != follow_entity:
		follow_entity = target
		time_since_saw_follow_entity = 0
		state = State.FOLLOW
	elif state != State.FOLLOW:
		follow_entity = null
	else:
		print("Already following entity: ", target)

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


