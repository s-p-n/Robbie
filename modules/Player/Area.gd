extends Area

var bodies = []
var ignored_bodies = [
	"Player",
	"LazerBeam",
	"Checkpoint",
	"Friend",
	"WaterBlob",
	"WireWhole"
]
onready var shape:BoxShape = $CollisionShape.shape
onready var mesh:Mesh = $MeshInstance.mesh
onready var position:Vector3 = Vector3.ZERO
onready var player = get_parent()

var throttle = 0.25
var t = 0

func _ready():
	pass
	
func _process_disabled(delta):
	t += delta
	if t <= throttle:
		return
	t = 0
	
	var resized = [0,0,0]
	position = global_transform.origin
	#mesh.get_aabb().intersects()
	for body in bodies:
		if !is_instance_valid(body):
			bodies.erase(body)
			continue
		
		if body.name in ignored_bodies:
			continue
		
		var body_position:Vector3 = body.global_transform.origin
		var collision_axis = (position - body_position).abs().min_axis()
		print("should resize because of collision with: ", body.name)
		print("distance: ", position.distance_to(body_position))
		print("direction: ", position.direction_to(body_position))
		print("shape: ", shape.extents)
		print("position: ", position)
		print("body position: ", body_position)
		print("collision axis: ", collision_axis)
		
		if shape.extents[collision_axis] > 0.5:
			shape.extents[collision_axis] -= 0.1
		
		if position[collision_axis] > body_position[collision_axis]:
			global_transform.origin[collision_axis] += 0
		else:
			global_transform.origin[collision_axis] -= 0
		resized[collision_axis] = 1
		position = global_transform.origin
	
	var i = -1
	print("resized: ", resized)
	for axis_val in resized:
		print('axis val:', axis_val)
		i += 1
		if axis_val != 1:
			shape.extents[i] += 0.1
			var player_diff = position[i] - player.global_transform.origin[i]
			if player_diff > 0:
				global_transform.origin[i] -= 0
			elif player_diff < 0:
				global_transform.origin[i] += 0
		print("shape ", shape.extents)
	
	mesh.size = shape.extents + shape.extents
	
func _on_body_entered(body):
	print("player body entered: ", body)
	bodies.append(body)


func _on_body_exited(body):
	print("player body exited: ", body)
	bodies.erase(body)

