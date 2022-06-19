extends RigidBody
onready var points = get_parent().get_parent().get_child(3)


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_parent().get_children():
		add_collision_exception_with(node)
	add_collision_exception_with(get_parent().get_parent())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	linear_velocity = Vector3(0,0,0)
