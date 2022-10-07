extends KinematicBody

signal boss_dead

export var cloudScene:PackedScene
export var health:int = 10
export var stamina:float = 100

onready var healthBarGreen = $HealthBarGreen
onready var healthBarRed = $HealthBarRed

var start_health = 10
var spawn_pos:Vector3

func _ready():
	spawn_pos = global_transform.origin
	start_health = health

func _on_Butt_body_entered(body):
	if body.name == "Player":
		if is_instance_valid(self):
			var cloud = cloudScene.instance()
			get_parent().add_child(cloud)
			if is_instance_valid(cloud):
				cloud.global_transform.origin = global_transform.origin - Vector3(0,1,0)
				print("created fart cloud")

func respawn():
	health = start_health
	global_transform.origin = spawn_pos
	update_health_visuals()

func adjust_stamina(_n):
	#stamina += n
	pass

func get_stamina():
	return stamina

func die():
	visible = false
	$Brain.die(self)
	emit_signal("boss_dead")
	
func handle_death():
	print("Fart Boss dead")
	queue_free()

func interact():
	health -= 1
	
	if health < 0:
		die()
	
	update_health_visuals()

func update_health_visuals():
	for i in range(10):
		var green_mesh:MeshInstance = healthBarGreen.get_child(9 - i)
		var red_mesh:MeshInstance = healthBarRed.get_child(9 - i)
		
		if i <= health:
			green_mesh.visible = true
		else:
			green_mesh.visible = false
		
		red_mesh.visible = !green_mesh.visible
