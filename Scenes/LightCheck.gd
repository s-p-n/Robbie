extends SpotLight
onready var pylon = get_parent().get_parent().get_parent()
var is_powered = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_power()
	change_color(is_powered)

func check_power():
	is_powered = pylon.is_powered
	
func change_color(has_power):
	if has_power:
		light_color = Color(255.0/255.0, 241.0/255.0, 31.0/255.0)
	else:
		light_color = Color(.9,.2,.2)
