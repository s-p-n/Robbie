extends Label

var hover_color = Color(0.73, 0.62, 0.22, 0.72)

func _on_Continue_gui_input(_event):
	if Input.is_action_just_released("leftclick"):
		find_parent("Paused").visible = false
