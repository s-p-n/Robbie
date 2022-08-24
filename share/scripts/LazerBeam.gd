extends RigidBody

onready var collisionShape = $CollisionShape
var host:Spatial = null
var hit = null
var can_hit = false
var hit_timer = .1
var cool_down_timer = hit_timer * 10
var time = 0
var change_stamina = -2.5 * (hit_timer * 10)
var cooling_down = false

func _ready():
	host = get_parent().get_parent().get_parent()
	if OK != connect("body_entered", self, "handle_contact"):
		print("LazerBeam cannot interact")
	add_collision_exception_with(host)

func _process(delta):
	if visible:
		$Sound.playing = true
	else:
		$Sound.playing = false
	
	if cooling_down and time < cool_down_timer:
		time += delta
		return
		
	if time < hit_timer:
		time += delta
		return
	time = 0
	cooling_down = false
	
	if visible:
		
		
		
		host.adjust_stamina(change_stamina)
		
		if host.get_stamina() <= -change_stamina:
			turn_off()
			cooling_down = true
			$CoolDown.playing = true
			print("laser low stamina")
			return
		
		if is_instance_valid(hit):
			print("Lazer interacting with: ", hit)
			hit.interact()
			hit = null
			turn_off()
			cooling_down = true
			print("laser hit")
			$CoolDown.playing = true
	else:
		$Sound.playing = false

func turn_on():
	if !cooling_down:
		visible = true
		collisionShape.disabled = false

func turn_off():
	visible = false
	collisionShape.disabled = true

func handle_contact(entity:Spatial):
	#print("laser hit something: ", entity)
	if is_instance_valid(entity) and entity.has_method("interact"):
		hit = entity
