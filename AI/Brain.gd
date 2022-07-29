extends Spatial

# Path to NPC's vision rays
export var ground_ray_path:NodePath
export var ahead_ray_path:NodePath

# Name of interesting objects
export(Array, String) var interesting_object_names

# Movement Speed
export var speed:float = 5.0

# How close we have to be to something to take an action
export var action_distance = 0.5

# The workings
onready var decide:Spatial = get_node("Decide")
onready var explore:Spatial = get_node("Explore")
onready var react:Spatial = get_node("React")

# Spatials we know about
var ground_ray:RayCast
var ahead_ray:RayCast

# Decision queue
var action = null

# Decision time
var delay = 0.25
var time = 0

func _ready():
	ground_ray = get_node(ground_ray_path)
	ahead_ray = get_node(ahead_ray_path)
	
func _process(delta):
	if not time_to_decide(delta):
		return
	
	if not take_next_action():
		explore.move_forward()
		pass
		#decide.make_decision()
	

func take_next_action():
	if action:
		#print("action: ", action)
		action["object"].callv(action["method"], action["args"])
		action = null
		return true
	return false

func queue_action(new_action):
	action = new_action


func time_to_decide(delta):
	increment_time(delta)
	
	if is_time_for_action():
		reset_time()
		return true
	
	return false

func is_time_for_action():
	return time >= delay

func reset_time():
	time = rand_range(-0.25, 0.25)

func increment_time(delta):
	time += delta
