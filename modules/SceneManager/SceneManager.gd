extends Spatial

signal level_loaded(level)

onready var active_level = $ActiveLevel
onready var wires = $PowerLines
onready var checkpoints = $Checkpoints
onready var shop = $Shop
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
	var level = levels[idx].instance()
	active_level.add_child(level)
	
	var player = active_level.get_child(0).find_node("Player")
	for item in shop.player_items:
		player.give_power(item)
	emit_signal("level_loaded", level)

func game_over():
	cur_level = 0
	UI.lives = starting_lives
	shop.player_items = []
	load_level(0)
