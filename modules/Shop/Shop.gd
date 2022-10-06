extends Control

var funds = 100 setget set_funds, get_funds

var player_items = ["Laser Gun"]

onready var itemList:ItemList = $Panel/ItemList
onready var cash = $Panel/Cash
onready var nextLevelBtn = $Panel/NextLevel
onready var arrow = $Arrow
onready var buyAudio = $Panel/BuyAudio
onready var closeAudio = $Panel/CloseAudio
onready var openAudio = $Panel/OpenAudio

var active = false

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	cash.text = str(funds)
	if get_parent().connect("level_loaded", self, "_on_level_loaded") != OK:
		print("HEY! Couldn't connect shop to level_loaded signal!")

func activate():
	active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true
	openAudio.play()
	itemList.grab_focus()
	#itemList.items[0].grab_focus()

func deactivate():
	active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	closeAudio.play()

func set_funds(new_funds):
	funds = new_funds
	cash.text = str(funds)
	print("funds set: ", funds)
	return funds

func get_funds():
	print("funds get: ", funds)
	return funds

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
	
	if item == "Laser Gun":
		nextLevelBtn.disabled = false
		arrow.visible = false
	
	var player = get_parent().get_node("ActiveLevel").get_child(0).find_node("Player")
	
	self.funds -= cost
	buyAudio.play(0)
	player_items.append(item)
	itemList.remove_item(items[0])
	get_node("Panel/Cost").text = "0"
	player.give_power(item)

func _on_NextLevel_pressed():
	if "Laser Gun" in player_items:
		deactivate()
		get_tree().root.get_node("Robbie").next_level()
	else:
		print("Laser Gun required to move on")

func _on_level_loaded(level):
	var ending = level.find_node("Ending")
	print("Level loaded.. Here is the ending: ", ending)
	itemList.shop_items = ending.shop_items
	itemList._ready()
