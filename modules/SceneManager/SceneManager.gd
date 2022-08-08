extends Spatial
onready var active_level = $ActiveLevel
onready var wires = $PowerLines
onready var checkpoints = $Checkpoints
onready var pause_menu = $Paused
onready var UI = $UI
var is_paused = false
var cur_level = 0
var starting_lives = 0


export (Array, PackedScene) var levels

func _ready():
	starting_lives = UI.lives
	load_level(cur_level)
	
func restart_level():
	load_level(cur_level)

func next_level():
	cur_level += 1
	if cur_level >= len(levels):
		cur_level = 0
	load_level(cur_level)

func load_level(idx):
	# Delete the Workshop Scene
	var old_level_members = active_level.get_children()
	var old_wires = wires.get_children()
	checkpoints.checkpoints_in_level = []
	
	for wire in old_wires:
		wire.queue_free()
	
	for active_scene_member in old_level_members:
		active_level.remove_child(active_scene_member)
		active_scene_member.queue_free()
	
	active_level.add_child(levels[idx].instance())

func game_over():
	cur_level = 0
	UI.lives = starting_lives
	load_level(0)
