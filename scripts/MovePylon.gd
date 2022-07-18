extends Spatial

export(String, "X", "Y", "Z") var open_axis = "X"
export var open_position:float = 0.0
export(float, 0, 25) var open_speed:float = 0.5

onready var audio_open = get_node("Source/doorOpen")
onready var audio_close = get_node("Source/doorClose")

var should_open = false
var should_close = false
var is_open = false
var is_closed = true
var open_direction
var source = null
var home_position:float = 0.0
var threshold = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	home_position = get_target_translation()
	if open_position < home_position:
		open_direction = true # should move number up
	else:
		open_direction = false # should move number down
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if should_open:
		if !is_open:
			handle_work(delta)
		else:
			should_open = false
	elif should_close:
		if !is_closed:
			handle_work_hault(delta)
	
	if (!source or !source.is_home):
		should_close = true
	#print("source is at home: ", (!source or !source.is_home))

func get_target_translation():
	if open_axis == 'X':
		return translation.x
	elif open_axis == 'Y':
		return translation.y
	elif open_axis == 'Z':
		return translation.z

func set_target_translation(new_val:float):
	if open_axis == 'X':
		translation.x = new_val
	elif open_axis == 'Y':
		translation.y = new_val
	elif open_axis == 'Z':
		translation.z = new_val

func open_door(delta:float):
	var cur = get_target_translation()
	if open_direction:
		#print(cur, " > ", open_position + threshold, " ", cur > (open_position + threshold))
		if cur > (open_position + threshold):
			return lerp(cur, open_position, delta * open_speed)
		else:
			is_open = true
	else:
		#print(cur, " < ", open_position - threshold, " ", cur < (open_position - threshold))
		if cur < (open_position - threshold):
			return lerp(cur, open_position, delta * open_speed)
		else:
			is_open = true
	return open_position
	
func close_door(delta:float):
	var cur = get_target_translation()
	if open_direction:
		if cur < (home_position - threshold):
			return lerp(cur, home_position, delta * open_speed)
		else:
			is_closed = true
	else:
		if cur > (home_position + threshold):
			return lerp(cur, home_position, delta * open_speed)
		else:
			is_closed = true
	return home_position

func work(new_source):
	audio_open.play(0.0)
	audio_close.stop()
	source = new_source
	should_open = true
	should_close = false

func handle_work(delta):
	is_closed = false
	set_target_translation(
		open_door(delta)
	)

func handle_work_hault(delta):
	should_open = false
	is_open = false
	source = null
	audio_open.stop()
	audio_close.play(0.0)
	set_target_translation(
		close_door(delta)
	)
