extends KinematicBody

export var health:int = 10
export var stamina:float = 100

onready var healthBarGreen = $HealthBarGreen
onready var healthBarRed = $HealthBarRed

var start_health = 10
var spawn_pos:Vector3

func _ready():
	spawn_pos = global_transform.origin
	start_health = health

func respawn():
	health = start_health
	global_transform.origin = spawn_pos
	update_health_visuals()

func adjust_stamina(n):
	#stamina += n
	pass

func get_stamina():
	return stamina

func interact():
	health -= 1
	
	if health < 0:
		queue_free()
	
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
