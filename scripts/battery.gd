extends RigidBody

const LAYER_BIT_OBSTICLE = 1
const LAYER_BIT_CLAW = 4
const MAX_POWER = 100
export(int, 0, 100) var power : int = 100

export var drain_time = 1
export var drain_amount = 1

var drain:float = 0

var is_powered = false
var is_home = false

var active_layers = []
var connection_home = null

onready var audio = find_node("audio")
onready var audio_drain = preload("res://Assets/audio/CG_GameSound_Selection_2.wav")
onready var dust_particles = preload("res://Scenes/particles/CleanParticle.tscn")
onready var green_light = preload("res://Assets/models/battery/progress_bar_green.tres")
onready var red_light = preload("res://Assets/models/battery/progress_bar_red.tres")
onready var player = find_parent("root").find_node("Player")

onready var level = get_child(7)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	setup_collisions()
	update_lights()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if find_parent("Robbie").is_paused:
		return
	if is_powered:
		drain += delta
		if drain >= drain_time:
			drain = 0;
			power -= drain_amount
			update_lights()
			
	if connection_home and !is_home:
		var dest = connection_home.get_transform()
		transform.origin = lerp(transform.origin, dest.origin, delta*5)
		rotation = lerp(rotation, connection_home.rotation, delta*5)
		
		if is_near_home():
			transform = dest
			is_home = true
			setup_collisions()
		else:
			gravity_scale = 0
			linear_velocity = Vector3(0, 0, 0)
	elif !connection_home and is_home:
		is_home = false
	elif connection_home and is_home:
		if is_near_home():
			gravity_scale = 0
			linear_velocity = Vector3(0, 0, 0)
		else:
			setup_collisions()
			is_home = false
	else:
		gravity_scale = 7

func update_lights():
	var total_lights = get_node('level').get_child_count()
	var power_level:float = float(power) / 100
	for i in range(total_lights):
		if power_level > float(i) / total_lights:
			level.get_child(i).material_override = green_light
		else:
			if level.get_child(i).material_override == green_light:
				audio.stream = audio_drain
				audio.play(0)
			level.get_child(i).material_override = red_light
	setup_collisions()
		

func is_near_home():
	if !connection_home:
		return false
	var dest = connection_home.get_transform()
	var diff = transform.origin - dest.origin
	diff = Vector3(abs(diff.x), abs(diff.y), abs(diff.z))
	return diff < Vector3(0.1, 0.1, 0.1)

func setup_collisions():
	var result = 0
	
	# always make it an obsticle
	active_layers = [LAYER_BIT_OBSTICLE, LAYER_BIT_CLAW]
	
	if is_home and is_near_home() and power > 0:
		is_powered = true
		find_node("SpotLight").visible = true
		attempt_to_power_circuit()
	else:
		is_powered = false
		find_node("SpotLight").visible = false
	
	for bit in active_layers:
		result += pow(2, bit - 1)
	
	collision_layer = result

func connect_to_home(new_home):
	connection_home = new_home
	setup_collisions()

func disconnect_from_home(old_home):
	if (connection_home == old_home):
		connection_home = null
	setup_collisions()

func attempt_to_power_circuit():
	if connection_home:
		var pylon = get_node_or_null(connection_home.connected_object)
		if pylon and pylon.has_method("set_power_source"):
			pylon.set_power_source(self)
