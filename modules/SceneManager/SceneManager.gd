extends Spatial
onready var active_level = $ActiveLevel
onready var wires = $PowerLines

var is_paused = false
var cur_level = 0

export (Array, PackedScene) var levels

func _ready():
	load_level(cur_level)

func restart_level():
	load_level(cur_level)

func next_level():
	if cur_level < len(levels):
		cur_level += 1
	else:
		cur_level = 0
	load_level(cur_level)

func load_level(idx):
	# Delete the Workshop Scene
	var old_level_members = active_level.get_children()
	var old_wires = wires.get_children()
	
	for wire in old_wires:
		wire.queue_free()
	
	for active_scene_member in old_level_members:
		active_scene_member.queue_free()
	
	active_level.add_child(levels[idx].instance())
