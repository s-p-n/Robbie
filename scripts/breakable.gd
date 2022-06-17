extends RigidBody

const MIN_DAMAGE:int = 0
const MAX_DAMAGE:int = 1
const MAX_HEAT:int = 1
const MIN_HEAT:int = 0


const LAYER_BIT_OBSTICLE = 1
const LAYER_BIT_CLAW = 4
const LAYER_BIT_BRUSH = 5
const LAYER_BIT_SOLDER = 7

export(int, 0, 10) var damage = 1
export(int, 0, 10) var heat = 0
export var is_soldered:bool = false
export var is_working:bool = false

var is_powered = false
var is_home = false

var active_layers = []
var connection_home = null


onready var dust_particles = preload("res://scenes/particles/CleanParticle.tscn")
onready var player = find_parent("root").find_node("Player")
onready var light = find_node("SpotLight")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	setup_collisions()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if connection_home and !is_home:
		var dest = connection_home.get_transform()
		transform.origin = lerp(transform.origin, dest.origin, delta*5)
		rotation = lerp(rotation, connection_home.rotation, delta*5)
		
		if is_near_home():
			transform = dest
			is_home = true
			setup_collisions()
			print("at home")
		else:
			gravity_scale = 0
			linear_velocity = Vector3(0, 0, 0)
			print("heading home")
	elif !connection_home and is_home:
		is_home = false
		print("lost connection, leaving home")
	elif connection_home and is_home:
		if is_near_home():
			gravity_scale = 0
			linear_velocity = Vector3(0, 0, 0)
		else:
			setup_collisions()
			is_home = false
			print("not near home anymore")
		#transform = connection_home.get_transform()
	else:
		gravity_scale = 7
		#linear_velocity = Vector3(0,-10,0)
	

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
			active_layers.append(LAYER_BIT_BRUSH)
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
	for bit in active_layers:
		print("collision bit ", bit, ": ", get_collision_layer_bit(bit - 1))
	print("collision result: ", result)
	print("Is Capacitor clawable: ", get_collision_layer_bit(3))
	print("Is Capacitor clawable: ", get_collision_layer_bit(4))
	print("is capacitor at home? ", is_home)
	print("is capacitor working? ", is_working)
	print("is capacitor powered? ", is_powered)

func repair():
	if damage > MIN_DAMAGE:
		var surface = $MeshInstance.get_surface_material(0).duplicate()
		damage -= 1
		print(surface)
		print("damage: ", damage)
		surface.roughness = damage / MAX_DAMAGE
		surface.normal_scale = surface.roughness * 16
		#surface.albedo_color = Color((35 + ((10 - damage) * 22))/255.0, (25 + ((10 - damage) * 23))/255.0, (25 + ((10 - damage) * 23))/255.0, 1)
		$MeshInstance.set_surface_material(0, surface)
		print(surface.roughness)
		surface = $MeshInstance.get_active_material(0)
	else:
		var surface = $MeshInstance.get_active_material(0)
		print(surface.roughness)
		print("Cleaned!")
	setup_collisions()

func heat():
	setup_collisions()
	print("connection home: ", connection_home)
	
	if connection_home == null:
		print("No connection to solder to.")
		return
	
	if damage != 0:
		if is_soldered:
			print("Soldered in place but damaged, should remove")
			return
		print("Too damaged to solder")
		return
	
	if is_soldered:
		if is_powered:
			print("Already in place and powered. Should work!")
			return
		else:
			print("Already in place, you should wire this.")
			return
	print("In place, not soldered, not damaged.")
	
	if heat < MAX_HEAT:
		heat += 1
	else:
		is_soldered = true
		print("Soldered in place")
		setup_collisions()
	print("heat: ", heat)

func spawn_particle(pos):
	var dust = dust_particles.instance()
	add_child(dust)
	dust.global_transform.origin = pos
	
	
func get_health():
	return damage
	
func clean ():
	repair()

func connect_to_home(new_home):
	print("Connecting to new home: ", new_home)
	connection_home = new_home
	setup_collisions()

func disconnect_from_home(old_home):
	print("Disconnecting from home: ", old_home)
	if (connection_home == old_home):
		connection_home = null
		print("disconnected")
	else:
		print("failed to disconnect")
		print(connection_home)
	setup_collisions()

func attempt_to_work():
	print("Capacitor is Attempting to make something work")
	
	if connection_home:
		var obj = get_node(connection_home.connected_object)
		print("Path to object: ", connection_home.connected_object)
		print("Object Capacitor should work with: ", obj)
		if obj and obj.has_method("work"):
			obj.work(self)
			indicate_working()
			print("Obj is now working.")
		else:
			print("Invalid connection. Set the 'Connected Object' property of the 'connection_home'. Select the path to the object you want to connect to.")
			display_error()

func display_error():
	light.light_color = Color(0.7, 0, 0)
	light.visible = true

func turn_off_light():
	light.light_color = Color(0.7, 0.7, 1)
	light.visible = false

func indicate_working():
	light.light_color = Color(0.7, 1, 0.7)
