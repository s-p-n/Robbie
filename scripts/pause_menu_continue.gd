extends Label

var hover_color = Color(0.73, 0.62, 0.22, 0.72)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Continue_gui_input(event):
	if Input.is_action_just_released("leftclick"):
		find_parent("Paused").visible = false
		print("clicked on continue")
