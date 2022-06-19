extends RigidBody

const MIN_DAMAGE:int = 0
const MAX_DAMAGE:int = 10
const MAX_HEAT:int = 10
const MIN_HEAT:int = 0


const LAYER_BIT_OBSTICLE = 1
const LAYER_BIT_CLAW = 4
const LAYER_BIT_VACUUM = 5
const LAYER_BIT_SOLDER = 7

export(int, 0, 10) var damage = 1
export(int, 0, 10) var heat = 0
export var is_soldered:bool = false
export var is_working:bool = false

var is_powered = false
var is_home = false
var is_solder_settling = false
var solder_settling_for:float = 0.0
export var solder_settle_time:float = 1.0


var active_layers = []
var connection_home = null

var vacuum_playing_for:float = 0.0
const vacuum_play_time:float = 2.0

onready var audio_after_solder = preload("res://Assets/audio/After Solder.wav")
export(Array, AudioStream) var audio_solder = [
	preload("res://Assets/audio/Mouth Solder-cm.wav"),
	preload("res://Assets/audio/Mouth Solder-cm_01.wav")
	preload("res://Assets/audio/Mouth Solder-cm_02.wav")
	preload("res://Assets/audio/Mouth Solder-cm_03.wav")
]

export(Array, AudioStream) var audio_vacuum = [
	preload("res://Assets/audio/CG_Modular_Vaccum.wav")
]

onready var audio_success = preload("res://Assets/audio/CG_GameSound_Puzzle_Solved-01.wav")
onready var audio_error = preload("res://Assets/audio/alert.wav")
onready var dust_particles = preload("res://Scenes/particles/CleanParticle.tscn")
onready var player = find_parent("root").find_node("Player")
onready var light = find_node("SpotLight")
onready var audio = find_node("audio_static")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	setup_collisions()


func _process(delta):
	
	if is_solder_settling:
		if solder_settling_for >= solder_settle_time:
			heat = 0
			is_solder_settling = false
			is_soldered = true
			setup_collisions()
		else:
			solder_settling_for += delta
	
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

func is_near_home():
	if !connection_home:
		return false
	var dest = connection_home.get_transform()
	var diff = transform.origin - dest.origin
	diff = Vector3(abs(diff.x), abs(diff.y), abs(diff.z))
	return diff < Vector3(0.1, 0.1, 0.1)

func setup_collisions():
	var result = 0
	is_working = false
	
	# always make it an obsticle
	active_layers = [LAYER_BIT_OBSTICLE, LAYER_BIT_CLAW]
	if is_soldered and is_home and is_near_home():
		find_node("SpotLight").visible = true
	elif !is_home and !is_near_home():
		is_soldered = false
		heat = MIN_HEAT
	
	if damage != 0:
		if is_soldered:
			active_layers.append(LAYER_BIT_SOLDER)
		else:
			active_layers.append(LAYER_BIT_VACUUM)
	elif !is_soldered: # if has no damage and is not soldered in place
		active_layers.append(LAYER_BIT_SOLDER)
	else: # if it is soldered in place and has no damage
		is_working = true
	
	# Handle Lights
	if is_home:
		if is_working:
			attempt_to_work()
		else:
			display_error()
	else:
		turn_off_light()
	
	for bit in active_layers:
		result += pow(2, bit - 1)
		
	collision_layer = result

func repair():
	if damage > MIN_DAMAGE:
		var surface = $MeshInstance.get_surface_material(0).duplicate()
		damage -= 1
		indicate_vacuum()
		surface.roughness = damage / MAX_DAMAGE
		surface.normal_scale = surface.roughness * 16
		#surface.albedo_color = Color((35 + ((10 - damage) * 22))/255.0, (25 + ((10 - damage) * 23))/255.0, (25 + ((10 - damage) * 23))/255.0, 1)
		$MeshInstance.set_surface_material(0, surface)
		surface = $MeshInstance.get_active_material(0)
	else:
		var surface = $MeshInstance.get_active_material(0)
	setup_collisions()

func solder():
	setup_collisions()
	
	if connection_home == null:
		return
	
	if damage != 0:
		if is_soldered:
			#Soldered in place but damaged, should remove
			return
		#Too damaged to solder
		return
	
	if is_soldered:
		if is_powered:
			#Already in place and powered. Should work!
			return
		else:
			#Already in place, you should wire this.
			return
	#In place, not soldered, not damaged.
	if heat == MAX_HEAT - 1:
		heat += 1
		is_solder_settling = true
		solder_settling_for = 0
		play_sound(audio_after_solder)
	elif heat < MAX_HEAT:
		heat += 1
		play_sound(audio_solder[round(
			rand_range(0,len(audio_solder) - 1))])

func spawn_particle(pos):
	var dust = dust_particles.instance()
	add_child(dust)
	dust.global_transform.origin = pos
	
	
func get_health():
	return damage
	
func clean ():
	repair()

func connect_to_home(new_home):
	connection_home = new_home
	setup_collisions()

func disconnect_from_home(old_home):
	if (connection_home == old_home):
		connection_home = null
	setup_collisions()

func attempt_to_work():
	if connection_home:
		var obj = get_node(connection_home.connected_object)
		if obj and obj.has_method("work"):
			obj.work(self)
			indicate_working()
		else:
			display_error()

func play_sound(stream):
	audio.stream = stream
	audio.play(0)

func display_error():
	if !light.visible or light.light_color != Color(0.7, 0, 0):
		play_sound(audio_error)
		light.light_color = Color(0.7, 0, 0)
	light.visible = true

func turn_off_light():
	light.light_color = Color(0.7, 0.7, 1)
	light.visible = false

func indicate_vacuum():
	play_sound(audio_vacuum[round(
			rand_range(0,len(audio_vacuum) - 1))])

func indicate_working():
	light.light_color = Color(0.7, 1, 0.7)
	play_sound(audio_success)
	

