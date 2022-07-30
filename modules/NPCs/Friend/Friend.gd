extends KinematicBody

var spawn_pos:Vector3

func _ready():
	spawn_pos = global_transform.origin

func respawn():
	global_transform.origin = spawn_pos
