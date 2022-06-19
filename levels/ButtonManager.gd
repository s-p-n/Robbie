extends Spatial
onready var root_manager = find_parent('Robbie')


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func load_level(level_string):
	root_manager.load_level(level_string)

func _on_Level1_pressed():
	load_level('level1')


func _on_Level2_pressed():
	load_level('level2')


func _on_Level3_pressed():
	load_level('level3')


func _on_Level4_pressed():
	load_level('level4')
