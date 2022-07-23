extends Label


func _on_Restart_gui_input(_event):
	if Input.is_action_just_released("leftclick"):
		find_parent("Robbie").get_node("ActiveLevel").get_child(0).find_node("Player").respawn()
		print("clicked on Restart Level")
