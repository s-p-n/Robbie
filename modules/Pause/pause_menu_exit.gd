extends Panel


func _on_Exit_gui_input(event):
	if event.is_action("leftclick") and event.is_pressed() and not event.is_echo():
		get_tree().quit()
