extends RigidBody

export var connected_object:NodePath = ""
export var is_connectable:bool = true
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("connected object path: ", connected_object)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_connection_home_body_entered(body):
	print("connection_home body_entered: ", body)
	if body and body.has_method("connect_to_home"):
		body.connect_to_home(self)


func _on_connection_home_body_exited(body):
	print("connection_home body_exited: ", body)
	if body and body.has_method("disconnect_from_home"):
		body.disconnect_from_home(self)
