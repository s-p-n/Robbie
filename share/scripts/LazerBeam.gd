extends RigidBody

onready var collisionShape = $CollisionShape

func _ready():
	if OK != connect("body_entered", self, "handle_contact"):
		print("LazerBeam cannot interact")
	add_collision_exception_with(get_parent().get_parent().get_parent())

func turn_on():
	visible = true
	collisionShape.disabled = false

func turn_off():
	visible = false
	collisionShape.disabled = true

func handle_contact(entity:Spatial):
	if is_instance_valid(entity) and entity.has_method("interact"):
		print("Lazer Beam Contact: ", entity)
		turn_off()
		entity.interact()
