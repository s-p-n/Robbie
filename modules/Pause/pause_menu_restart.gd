extends Label


func _on_Restart_gui_input(event):
	if event.is_action("leftclick") and event.is_pressed() and not event.is_echo():
		find_parent("Robbie").get_node("ActiveLevel").get_child(0).find_node("Player").respawn()
		print("clicked on Restart Level")
