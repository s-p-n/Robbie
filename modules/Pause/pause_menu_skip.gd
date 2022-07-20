extends Label

func _on_Skip_gui_input(_event):
	if Input.is_action_just_released("leftclick"):
		find_parent("Robbie").next_level()
		print("clicked on Restart Level")
