# Singleton

extends Control


func _ready():
	pause_mode = PAUSE_MODE_PROCESS # This script can't get paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event.is_action("ui_cancel") and event.is_pressed() and not event.is_echo():
		toggle_pause()

func _process(_delta):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		visible = true
		get_tree().paused = true
	else:
		visible = false
		get_tree().paused = false

func toggle_pause():
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _on_Paused_gui_input(event):
	if event.is_action("leftclick") and event.is_pressed() and not event.is_echo():
		toggle_pause()
