extends Spatial
onready var cameras = $Cameras
onready var active_level = $ActiveLevel
onready var wires = $Wires
var update_time = 0

var workshop_camera = preload("res://scenes/WorkshopCamera.tscn")
var workshop = preload("res://levels/WorkshopScene.tscn")
var level_1 = preload("res://levels/first_1.tscn")
var level_2 = preload("res://levels/Pipeline_2.tscn")
var level_3 = preload("res://levels/cellphone.tscn")
var level_4 = preload("res://levels/level_4.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#cameras.add_child(workshop_camera)
	
	#Comment this line below to see player camera.
	#$Cameras/WorkshopCamera/Camera.current = true	
	
	# LOADS WORKSHOP SCENE
	#load_level('workshop')
	
	# LOADS LEVEL 1
	#load_level('level1')
	
	# LOADS LEVEL 2
	#load_level('level2')
	
	# LOADS LEVEL 3
	#load_level('level3')
	
	# LOADS LEVEL 4
	load_level('level4')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_time += delta



func load_level(level_name):
	# Delete the Workshop Scene
	var old_levels = active_level.get_children()
	for active_scene in old_levels:
		active_scene.queue_free()
	# Load the level
	if level_name == 'workshop':
		active_level.add_child(workshop.instance())
	elif level_name == 'level1':
		active_level.add_child(level_1.instance())
	elif level_name == 'level2':
		active_level.add_child(level_2.instance())
	elif level_name == 'level3':
		active_level.add_child(level_3.instance())
	elif level_name == 'level4':
		active_level.add_child(level_4.instance())
		
