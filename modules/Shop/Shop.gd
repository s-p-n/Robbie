extends Control

onready var itemList:ItemList = $Panel/ItemList

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

func _on_Buy_pressed():
	var items = itemList.get_selected_items()
	if len(items) == 0:
		return
	var item = itemList.get_item_text(items[0])
	print("User wants to buy: ", item)
	
