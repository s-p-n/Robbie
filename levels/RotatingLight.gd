extends DirectionalLight

export var speed = 1
var cur_rotation = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var is_spinning = true
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_spinning:
		cur_rotation = lerp(cur_rotation, 0, delta * speed * 0.1)
	else:
		cur_rotation = delta * speed
	self.rotate_z(cur_rotation)
