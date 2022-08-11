extends RigidBody

onready var collisionShape = $CollisionShape
var host:Spatial = null
var hit = null
var can_hit = false
var hit_timer = 0.1
var time = 0
var change_stamina = -5

func _ready():
	host = get_parent().get_parent().get_parent()
	if OK != connect("body_entered", self, "handle_contact"):
		print("LazerBeam cannot interact")
	add_collision_exception_with(host)

func _process(delta):
	if time < hit_timer:
		time += delta
		return
	
	if host.get_stamina() < 10:
		turn_off()
		return
	
	if visible:
		time = 0
		host.adjust_stamina(change_stamina)
	
		if is_instance_valid(hit):
			print("Lazer interacting with: ", hit)
			hit.interact()
			hit = null
		

func turn_on():
	visible = true
	collisionShape.disabled = false

func turn_off():
	visible = false
	collisionShape.disabled = true

func handle_contact(entity:Spatial):
	print("laser hit something: ", entity)
	if is_instance_valid(entity) and entity.has_method("interact"):
		hit = entity
