extends MeshInstance

var direction = true

func _ready():
	rotation_degrees = Vector3(rand_range(-360.0, 360.0), rand_range(-360.0, 360.0), rand_range(-360.0, 360.0))

func _process(delta):
	var r = delta * 50
	
	if r > 360:
		direction = false
	elif r < -359:
		direction = true
	
	if direction:
		rotation_degrees += Vector3(r, r, r)
	else:
		rotation_degrees -= Vector3(r, r, r)
