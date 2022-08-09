extends Spatial

export(String, "Select Power", "Laser Gun", "Extra Life", "Wings") var power

onready var shape:RigidBody = $Shape

func _physics_process(delta):
	var r = delta * 50
	shape.rotation_degrees += Vector3(r, r, r)
	

func _on_Shape_body_entered(body):
	print("collision with power-up: ", body)
	if is_instance_valid(body) and body.name == "Player":
		body.give_power(power)
		queue_free()
