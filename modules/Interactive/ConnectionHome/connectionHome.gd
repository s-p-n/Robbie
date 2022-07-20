extends RigidBody

export var connected_object:NodePath = ""
export var is_connectable:bool = true

func _on_connection_home_body_entered(body):
	if body and body.has_method("connect_to_home"):
		print('enter ', body)
		body.connect_to_home(self)

func _on_connection_home_body_exited(body):
	if body and body.has_method("disconnect_from_home"):
		print('exit ', body)
		body.disconnect_from_home(self)
