extends Spatial

signal tick(delta)

# Path to NPC's vision rays
export var ground_ray_path:NodePath
export var ground_ahead_ray_path:NodePath
export var ahead_ray_path:NodePath
export var jump_ray_path:NodePath

# Name of objects this AI will look for
export(Array, String) var seek_out_object_names

# Name of objects this AI will interact with
export(Array, String) var interact_with_object_names

# Bahaviors
export(Dictionary) var behaviors = {
	"Explore": true,
	"Attempt Platforming": false,
	
}

# Movement Speed
export var speed:float = 5.0

# How close we have to be to something to take an action
export var action_distance = 0.5

# The workings
onready var decide:Spatial = get_node("Decide")
onready var explore:Spatial = get_node("Explore")
onready var react:Spatial = get_node("React")

onready var vision:Spatial = get_parent().get_node("Vision")

# Spatials we know about
var ground_ray:RayCast
var ground_ahead_ray:RayCast
var ahead_ray:RayCast
var jump_ray:RayCast

var entity:KinematicBody
# Decision queue
var action = null

# Decision time
var delay = 0.25
var time = 0

var lazer_state = false

func _ready():
	ground_ray = get_node(ground_ray_path)
	ground_ahead_ray = get_node(ground_ahead_ray_path)
	ahead_ray = get_node(ahead_ray_path)
	jump_ray = get_node(jump_ray_path)
	entity = get_parent()
	
func _process(delta):
	emit_signal("tick", delta)
	if not time_to_decide(delta):
		return
	lazer_state = !lazer_state
	if not take_next_action():
		decide.make_decision()

func take_next_action():
	if action:
		action["object"].callv(action["method"], action["args"])
		action = null
		return true
	return false

func queue_action(new_action):
	if !action or new_action["weight"] > action["weight"]:
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
