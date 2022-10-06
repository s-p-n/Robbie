extends Spatial

export(String, "Select Power", "Laser Gun", "Extra Life", "Wings") var power

onready var shape:RigidBody = $Shape
onready var collectSound:AudioStreamPlayer3D = $CollectSound

var direction = true

func _physics_process(delta):
	var r = delta * 50
	
	if r > 360:
		direction = false
	elif r < -359:
		direction = true
	
	if direction:
		shape.rotation_degrees += Vector3(r, r, r)
	else:
		shape.rotation_degrees -= Vector3(r, r, r)

func _on_Shape_body_entered(body):
	print("collision with power-up: ", body)
	if is_instance_valid(body) and body.name == "Player":
		body.give_power(power)
		
		if !collectSound.playing:
			collectSound.play(0)
			shape.visible = false
			collectSound.connect("finished", self, "_handle_removal")

func _handle_removal():
	queue_free()
