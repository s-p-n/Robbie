extends RigidBody

const MIN_DAMAGE:int = 0
const MAX_DAMAGE:int = 10
const MAX_HEAT:int = 10
const MIN_HEAT:int = 0


const LAYER_BIT_OBSTICLE = 1
const LAYER_BIT_CLAW = 4
const LAYER_BIT_BRUSH = 5
const LAYER_BIT_SOLDER = 7

export(int, 0, 10) var damage = 10
export(int, 0, 10) var heat = 0
export var is_soldered:bool = false
export var is_working:bool = false

var is_powered = false

var active_layers = []
var connection_home = null


onready var dust_particles = preload("res://scenes/particles/CleanParticle.tscn")
onready var player = find_parent("root").find_node("Player")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	setup_collisions()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	linear_velocity = Vector3(0,-10,0)
	#setup_collisions()
	pass

func setup_collisions():
	var result = 0
	is_working = false
	
	if is_soldered: # cannot move if soldered
		mode = MODE_STATIC
	else:
		mode = MODE_RIGID
	
	# always make it an obsticle
	active_layers = [LAYER_BIT_OBSTICLE]
	if damage != 0:
		if is_soldered:
			active_layers.append(LAYER_BIT_SOLDER)
		else:
			active_layers.append(LAYER_BIT_CLAW)
			active_layers.append(LAYER_BIT_BRUSH)
	elif !is_soldered: # if has no damage and is not soldered in place
		active_layers.append(LAYER_BIT_CLAW)
		active_layers.append(LAYER_BIT_SOLDER)
	else: # if it is soldered in place and has no damage
		is_working = true
	
	for bit in active_layers:
		result += pow(2, bit - 1)
		
	collision_layer = result
	
	print("is capacitor working? ", is_working)
	

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


func _on_capacitor_body_entered(body):
	print("capacitor body entered: ", body)
	pass # Replace with function body.


func _on_capacitor_body_exited(body):
	print("capacitor body exited: ", body)
	pass # Replace with function body.
