extends Spatial

onready var cam = $WorkshopCamera
onready var positions = [ $Positions/Position1, $Positions/Position2, $Positions/Position3, $Positions/Position4 ]
onready var interfaces = [ $Interfaces/View1, $Interfaces/View2, $Interfaces/View3, $Interfaces/View4]
var camera_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_other_interfaces_vis()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("left"):
		print("Left Pressed")
		if camera_index < 1:
			print("Index Number: ", camera_index)
			print("Returned")
			return
		camera_index -= 1
		print("Index Number: ", camera_index)
		cam.set_target(positions[camera_index])
		set_other_interfaces_vis()
	elif Input.is_action_just_pressed("right"):
		print("Right Pressed")
		if camera_index <= len(positions):
			print("Index Number: ", camera_index)
			print("Returned")
			return
		camera_index += 1
		print("Index Number: ", camera_index)
		cam.set_target(positions[camera_index])
		set_other_interfaces_vis()


func set_other_interfaces_vis():
	# Set all Interface visibilities to FALSE
	interfaces[0].visible = false
	interfaces[1].visible = false
	interfaces[camera_index].visible = true
