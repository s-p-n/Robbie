extends Label

func _on_Skip_gui_input(event):
	if event.is_action("leftclick") and event.is_pressed() and not event.is_echo():
		print("clicked on Next Level")
		find_parent("Robbie").next_level()
		find_parent("Paused").toggle_pause()
