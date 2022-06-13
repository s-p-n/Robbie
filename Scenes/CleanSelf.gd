extends RigidBody
var health
var dust_particles = preload("res://scenes/particles/CleanParticle.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	health = 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass`



func clean():
	if health > 0:
		var surface = $MeshInstance.get_surface_material(0).duplicate()
		health -= 1
		print(surface)
		print("Health: ", health)
		surface.albedo_color = Color((35 + ((10 - health) * 22))/255.0, (25 + ((10 - health) * 23))/255.0, (25 + ((10 - health) * 23))/255.0, 1)
		$MeshInstance.set_surface_material(0, surface)
		print(surface.albedo_color)
		surface = $MeshInstance.get_active_material(0)
	else:
		var surface = $MeshInstance.get_active_material(0)
		print(surface.albedo_color)
		print("Cleaned!")
		
func spawn_particle(pos):
	var dust = dust_particles.instance()
	add_child(dust)
	dust.global_transform.origin = pos
	
	
func get_health():
	return health
	
	


