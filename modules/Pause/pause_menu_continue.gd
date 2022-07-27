extends Label

var hover_color = Color(0.73, 0.62, 0.22, 0.72)

func _on_Continue_gui_input(event):
	if event.is_action("leftclick") and event.is_pressed() and not event.is_echo():
		find_parent("Paused").toggle_pause()
