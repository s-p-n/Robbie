extends Spatial
var is_powered:bool
onready var platform = $Platform
var moving_upwards
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	moving_upwards = true
	is_powered = get_parent().is_powered
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_direction()
	check_power()
	if is_powered:
		if moving_upwards:
			lerp(transform.origin.y, 9, delta * 2)
		else:
			lerp(transform.origin.y, 1, delta * 2)
			
	


func check_direction():
	if transform.origin.y >= 9:
		moving_upwards = false
	else:
		moving_upwards = true
func check_power():
	is_powered = get_parent().is_powered
	
func work(source):
	if source:
		print(source)
