extends KinematicBody

#signal power_lost

const LAYER_BIT_OBSTICLE = 1
const LAYER_BIT_CLAW = 4
const MAX_POWER = 100
const VELOCITY_CLAMP = 0.25

export(int, 0, 100) var power : int = 100

export var drain_time = 1
export var drain_amount = 1

export var green_light:SpatialMaterial
export var red_light:SpatialMaterial

var drain:float = 0

var is_powered = false
var is_home = false

var active_layers = []
var connection_home = null
var last_number_of_green:int = 0
var linear_velocity:Vector3 = Vector3.ZERO
var gravity_scale:float = 0
onready var audio = find_node("audio")
#onready var green_light = preload("res://scripts/textures/progress_bar_green.tres")
#onready var red_light = preload("res://modules/Interactive/Battery/progress_bar_red.tres")
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
func _physics_process(delta):
	if is_powered:
		drain += delta
		if drain >= drain_time:
			drain = 0;
			power -= drain_amount
			update_lights()
	
	#linear_velocity = calculate_velocity(delta)
		
	#print(linear_velocity)
	if connection_home and !is_home:
		var dest = connection_home.global_transform.origin
		global_transform.origin = lerp(global_transform.origin, dest, delta*5)
		#rotation = lerp(rotation, connection_home.rotation, delta*5)
		#print('a')
		if is_near_home():
			#transform = dest
			is_home = true
			setup_collisions()
		else:
			gravity_scale = 0
			linear_velocity = Vector3(0, 0, 0)
	elif !connection_home and is_home:
		is_home = false
		#print('b')
	elif connection_home and is_home:
		#print('c')
		if is_near_home():
			gravity_scale = 0
			linear_velocity = Vector3(0, 0, 0)
		else:
			setup_collisions()
			is_home = false
	else:
		#print('d')
		gravity_scale = 1

func calculate_velocity(_delta):
	var _max = VELOCITY_CLAMP
	var _min = -VELOCITY_CLAMP
	
	
	

func update_lights():
	var total_lights = get_node('level').get_child_count()
	var power_level:float = float(power) / 100
	var number_of_green = 0
	for i in range(total_lights):
		if power_level > float(i) / total_lights:
			level.get_child(i).material_override = green_light
			number_of_green += 1
		else:
			level.get_child(i).material_override = red_light
	if is_near_home():
		if number_of_green != last_number_of_green:
			last_number_of_green = number_of_green
			if number_of_green == 0:
				audio.stop()
			else:
				audio.pitch_scale = number_of_green * 0.1
				audio.play()
		setup_collisions()
		

func is_near_home():
	if !connection_home:
		return false
	var dest = connection_home.global_transform.origin
	var diff = global_transform.origin - dest
	diff = Vector3(abs(diff.x), abs(diff.y), abs(diff.z))
	return diff < Vector3(0.1, 0.1, 0.1)

func setup_collisions():
	var result = 0
	
	# always make it an obsticle
	active_layers = [LAYER_BIT_OBSTICLE, LAYER_BIT_CLAW]
	
	if is_home and is_near_home() and power > 0:
		is_powered = true
		find_node("SpotLight").visible = true
		attempt_to_power_object()
	else:
		is_powered = false
		find_node("SpotLight").visible = false
		attempt_to_shutdown_object()
	
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

func attempt_to_power_object():
	if connection_home:
		var object = connection_home.connected_object
		print("Attempting to power object: ", object)
		if object and object.has_method("set_power_source"):
			object.set_power_source(self)

func attempt_to_shutdown_object():
	if connection_home:
		var object = connection_home.connected_object
		print("Attempting to shut down object: ", object)
		if object and object.has_method("unset_power_source"):
			object.unset_power_source()
