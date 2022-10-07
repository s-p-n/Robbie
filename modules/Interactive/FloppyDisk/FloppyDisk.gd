extends Area


export var rotation_speed:float
export var audio_file:AudioStream
export(Array, String) var subtitle_lines
export(Array, float) var subtitle_line_time

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	rotate_y(delta * rotation_speed)


func _on_FloppyDisk_body_entered(body):
	if body.name == "Player":
		body.play_log_file(audio_file, subtitle_lines, subtitle_line_time)
