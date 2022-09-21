extends Control

var funds = 5

var player_items = []

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
	var cost = itemList.item_prices[item]
	
	if funds < cost:
		print("Not enough funds.")
		return
	
	funds -= cost
	player_items.append(item)
	itemList.remove_item(items[0])
	
	var player = get_parent().get_node("ActiveLevel").get_child(0).find_node("Player")
	player.give_power(item)

func _on_NextLevel_pressed():
	if "Laser Gun" in player_items:
		deactivate()
		get_tree().root.get_node("Robbie").next_level()
	else:
		print("Laser Gun required to move on")
