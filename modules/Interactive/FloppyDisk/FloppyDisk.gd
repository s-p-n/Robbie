extends Area


export var rotation_speed:float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	rotate_y(delta * rotation_speed)
