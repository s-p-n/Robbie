extends RigidBody

onready var powerline = get_parent()
onready var mesh = $Mesh
var material:SpatialMaterial = SpatialMaterial.new()
var color_set = false

func _ready():
	mesh.set_surface_material(0, material)

func _process(_delta):
	if !color_set and is_instance_valid(powerline.pair[0]):
		color_set = true
		material.albedo_color = powerline.pair[0].pylon.output_color

func _on_WireWhole_body_entered(body):
	var pylons = [powerline.pair[0].pylon, powerline.pair[1].pylon]
	if !(body in pylons or body == powerline.player):
		print("collided with: ", body)
		print(pylons)
		powerline.disconnect_pair()
