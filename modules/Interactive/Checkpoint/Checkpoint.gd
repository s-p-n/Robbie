extends RigidBody

export var flag_unset:Material
export var flag_set:Material

onready var checkpoint_pos = global_transform.origin
onready var checkpoints = find_parent("Robbie").get_node("Checkpoints")
onready var mesh = $Mesh

var is_preloaded = false

var player:KinematicBody = null

func _ready():
	var level = find_parent("Level")
	if is_instance_valid(level):
		player = level.find_node("Player")
		mesh.set_surface_material(1, flag_unset)
		call_deferred("setup")
		print('checkpoint ready')
	else:
		print("Checkpoint cannot be setup outside of a level.")

func setup():
	checkpoints.checkpoints_in_level.append(self)

func _on_Checkpoint_body_entered(body):
	if body == player:
		set_this_checkpoint()

func set_this_checkpoint():
	if is_instance_valid(player) and player.last_checkpoint != self:
		#print("Setting this checkpoint: ", self)
		var siblings = checkpoints.get_children()
		player.checkpoint(self)
		for sibling in siblings:
			sibling.mesh.set_surface_material(1, flag_unset)
		mesh.set_surface_material(1, flag_set)
		print("Set checkpoint to self: ", self)
	else:
		print("Cannot set checkpoint")
		print('player valid? ', is_instance_valid(player))
		print(player.last_checkpoint, " != ", self, '? ', player.last_checkpoint != self)