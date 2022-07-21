extends RigidBody

export var flag_unset:Material
export var flag_set:Material

onready var checkpoint_pos = global_transform.origin
onready var player = find_parent("Level").find_node("Player")
onready var checkpoints = find_parent("Robbie").get_node("Checkpoints")
onready var mesh = $Mesh

var is_preloaded = false

func _ready():
	mesh.set_surface_material(1, flag_unset)
	call_deferred("setup")
	preload_flag()

func setup():
	get_parent().remove_child(self)
	checkpoints.add_child(self)
	set_owner(checkpoints)

func _on_Checkpoint_body_entered(body):
	if body == player:
		set_this_checkpoint()

func set_this_checkpoint():
	if mesh.mesh.surface_get_material(1) != flag_set:
		#print("Setting this checkpoint: ", self)
		var siblings = checkpoints.get_children()
		player.checkpoint()
		for sibling in siblings:
			sibling.mesh.set_surface_material(1, flag_unset)
		mesh.set_surface_material(1, flag_set)

func preload_flag():
	if !is_preloaded:
		is_preloaded = true
		mesh.set_surface_material(1, flag_set)
		call_deferred("preload_flag")
	else:
		mesh.set_surface_material(1, flag_unset)
