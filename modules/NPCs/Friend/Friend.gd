extends KinematicBody

var spawn_pos:Vector3
var held_wire = null

export var health:int = 10
export var stamina:float = 100

onready var healthBarGreen = $HealthBarGreen
onready var healthBarRed = $HealthBarRed

func _ready():
	spawn_pos = global_transform.origin

func interact():
	health -= 1
	
	if health < 0:
		respawn()
	
	update_health_visuals()
	

func adjust_stamina(n):
	stamina += n

func get_stamina():
	return stamina

func die():
	if held_wire:
		held_wire.interact()
		held_wire = null
	queue_free()

func respawn():
	if is_instance_valid(held_wire):
		held_wire.interact()
		held_wire = null
	global_transform.origin = spawn_pos
	
func update_health_visuals():
	for i in range(10):
		var green_mesh:MeshInstance = healthBarGreen.get_child(9 - i)
		var red_mesh:MeshInstance = healthBarRed.get_child(9 - i)
		
		if i <= health:
			green_mesh.visible = true
		else:
			green_mesh.visible = false
		
		red_mesh.visible = !green_mesh.visible
