extends Spatial
onready var cameras = $Cameras
onready var world = $World
onready var env = $Environment

var workshop_camera = preload("res://scenes/WorkshopCamera.tscn").instance()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	cameras.add_child(workshop_camera)
	$Cameras/WorkshopCamera/Camera.current = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
