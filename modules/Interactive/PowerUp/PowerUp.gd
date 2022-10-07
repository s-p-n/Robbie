extends Spatial

export(String, "Select Power", "Laser Gun", "Extra Life", "Wings") var power

onready var shape:RigidBody = $Shape
onready var collectSound:AudioStreamPlayer3D = $CollectSound

var direction = true

func _process(delta):
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
	#print("collision with spare: ", body)
	if is_instance_valid(body) and body.name == "Player":
		
		if !collectSound.playing:
			collectSound.play(0)
			body.collect_spare()
			shape.visible = false
			if !collectSound.connect("finished", self, "_handle_removal"):
				print("Warning: Spare cannot connect to audio finish signal.")

func _handle_removal():
	queue_free()
