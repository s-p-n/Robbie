extends Control

var active = false

func _ready():
	pause_mode = PAUSE_MODE_PROCESS

func activate():
	active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true

func deactivate():
	active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	


func _on_Close_pressed():
	deactivate()
