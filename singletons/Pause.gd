# Singleton

extends Control


func _ready():
	pause_mode = PAUSE_MODE_PROCESS # This script can't get paused
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.is_action_just_pressed("tilda"):
		visible = !visible

func _process(event):
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = visible
		


func _on_Paused_gui_input(event):
	if Input.is_action_just_released("leftclick"):
		visible = false
