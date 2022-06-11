extends Camera

export var camera_move_speed = .08

var target
var t = 0.0


var view
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	if !target:
		return
	transform = transform.interpolate_with(target.transform, camera_move_speed)
	
	
	
func set_target(pos):
	target = pos
