extends Spatial

onready var cam = $Camera
onready var positions = [ $Positions/Position1, $Positions/Position2, $Positions/Position3, $Positions/Position4 ]
onready var interfaces = [ $Interfaces/View1, $Interfaces/View2, $Interfaces/View3, $Interfaces/View4 ]
var camera_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_other_interfaces_vis()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("left"):
		if camera_index < 1:
			return
		camera_index -= 1
		cam.set_target(positions[camera_index])
		set_other_interfaces_vis()
	elif Input.is_action_just_pressed("right"):
		if camera_index >= (len(positions) - 1):
			return
		camera_index += 1
		cam.set_target(positions[camera_index])
		set_other_interfaces_vis()


func set_other_interfaces_vis():
	# Set all Interface visibilities to FALSE at Start
	interfaces[0].visible = false
	interfaces[1].visible = false
	interfaces[2].visible = false
	interfaces[3].visible = false
	# Enable interface that is currently viewed
	interfaces[camera_index].visible = true
