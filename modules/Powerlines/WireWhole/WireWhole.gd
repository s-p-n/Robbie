extends RigidBody

onready var powerline = get_parent()
onready var mesh = $Mesh
var material:SpatialMaterial = SpatialMaterial.new()
var color_set = false
var wire_health = -1
var player:KinematicBody

func _ready():
	player = find_parent("Robbie").get_node("ActiveLevel").get_child(0).find_node("Player")
	mesh.set_surface_material(0, material)
	print("wirewhole player:", player)

func _process(_delta):
	if !color_set and is_instance_valid(powerline.pair[0]):
		color_set = true
		material.albedo_color = powerline.pair[0].pylon.output_color
	#if !is_instance_valid(powerline.pair[1]):
	#	if powerline.entity.distance_to()

func _on_WireWhole_body_entered(body):
	var pylons = [powerline.pair[0].pylon, powerline.pair[1].pylon]
	if !(body in pylons or body == powerline.player):
		print("collided with: ", body)
		print(pylons)
		powerline.disconnect_pair()

func interact():
	if wire_health == -1:
		if is_instance_valid(player):
			wire_health = player.wire_health
		else:
			wire_health = 1
	
	print("wire under attack: ", wire_health)
	wire_health -= 1
	
	if wire_health <= 0:
		powerline.disconnect_pair()
