extends Panel


func _on_Exit_gui_input(_event):
	if Input.is_action_just_released("leftclick"):
		get_tree().quit()
