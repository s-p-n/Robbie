extends RigidBody

export var connected_object_path:NodePath = ""
export var is_connectable:bool = true

var connected_object:Spatial
var interact:Spatial

func _ready():
	interact = find_parent("Objects").find_node("Player").get_node("Head/Interact")
	print('interact', interact)
	connected_object = get_node_or_null(connected_object_path)

func _on_connection_home_body_entered(body):
	if is_instance_valid(interact) and is_instance_valid(body) and body.has_method("connect_to_home") and body != interact.held_object:
		print('enter ', body)
		body.connect_to_home(self)

func _on_connection_home_body_exited(body):
	if body and body.has_method("disconnect_from_home"):
		print('exit ', body)
		body.disconnect_from_home(self)
