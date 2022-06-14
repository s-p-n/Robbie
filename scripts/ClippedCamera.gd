extends ClippedCamera

onready var player = find_parent("Player")
onready var holder = find_parent("cameraHolder")

export var max_zoom : float = 12
export var min_zoom : float = 3
export var zoom_speed : float = 16
export var zoom_step : float = 1
export var zoom_y_multiple : float = 0.075

var zoom_y_level = 4
var zoom_level = max_zoom / 2
var y_offset : float = 4
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_released("zoom_in")):
		zoom_level -= zoom_step;
	
	if (Input.is_action_just_released("zoom_out")):
		zoom_level += zoom_step
	
	if (zoom_level < min_zoom):
		zoom_level = min_zoom
	
	if (zoom_level > max_zoom):
		zoom_level = max_zoom
	
	zoom_y_level = 4 + (zoom_level * zoom_y_multiple)
	var cam_pos = self.global_transform.origin
	var cam_dest = cam_pos + Vector3(0, zoom_y_level, 0)
	
	#print("Zoom level: ", zoom_level, " y-level: ", zoom_y_level)
	y_offset = lerp(y_offset, zoom_y_level, delta * zoom_speed)
	
	#self.set_translation(cam_pos + Vector3(0, y_offset, 0))
	holder.spring_length = lerp(holder.spring_length, zoom_level, zoom_speed * delta)
	#holder. = ( Vector3(0, zoom_y_level, 0), zoom_speed * delta)
