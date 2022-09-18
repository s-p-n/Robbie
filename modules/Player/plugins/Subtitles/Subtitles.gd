extends LineEdit


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var time
var subtitles_active = false
var subtitle_start_time = 0.0
var content = []
var time_per_line = []

# Called when the node enters the scene tree for the first time.
func _ready():
	time = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if subtitles_active:
		if time > (subtitle_start_time + time_per_line[0]):
			time_per_line.pop_at(0)
			content.pop_at(0)
			
			if content.size() == 0:
				# Set active to false so you don't get index access error.
				subtitles_active = false
			else:
				# Otherwise, set the start_time to the new time.
				subtitle_start_time = time
		else:
			text = content[0]
	else:
		text=''
		



func init_subtitles(sub_content : Array, sub_time_per_line : Array):
	# This function takes in 2 arrays.
	# sub_content (Each line is a single string stored in this array. They are stored in order.
	# sub_time_per_line (Number of seconds that it will display the line with the SAME index number.)
	# So if you have a sub_content of ['Hello World'] and sub_time_per_line of [4]
	# The subtitles will display Hello World for 4 seconds.
	if content.size() != time_per_line.size():
		# If there isn't a time_per_line for each line, don't run the script.
		print("Error: Invalid subtitles parameters.")
		return
	time_per_line = sub_time_per_line
	content = sub_content
	subtitles_active = true
