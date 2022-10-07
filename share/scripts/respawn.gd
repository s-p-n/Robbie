extends RigidBody

func _on_platform_body_entered(body):
	if body.has_method("respawn"):
		print("Respawning Body: ", body)
		body.respawn()
	else:
		print("Body has no method 'respawn()' yet collided with respawner! Fix This!")
		print("Body: ", body)
