extends Control

var funds = 50 setget set_funds, get_funds

export(Dictionary) var item_prices = {
	"Laser": 5,
	"Recharge": 5,
	"Thrust": 5
}

#var player_items = ["Thrust"]

#onready var itemList:ItemList = $Panel/ItemList
#onready var cash = $Panel/Cash
onready var nextLevelBtn = $NextLevel/NextLevel
onready var arrow = $Arrow

onready var UI = get_parent().get_node("UI")

var active = false

func _ready():
	if get_parent().connect("level_loaded", self, "_on_level_loaded") != OK:
		print("HEY! Couldn't connect shop to level_loaded signal!")
	set_funds(funds)

func activate():
	active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true
	
	if !is_instance_valid(UI):
		UI = get_parent().get_node("UI")
	
	UI.get_node("IconSidebar/Laser/Upgrade").visible = true
	UI.get_node("IconSidebar/Thrust/Upgrade").visible = true
	UI.get_node("IconSidebar/Recharge/Upgrade").visible = true

func deactivate():
	active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	
	if !is_instance_valid(UI):
		UI = get_parent().get_node("UI")
	
	UI.get_node("IconSidebar/Laser/Upgrade").visible = false
	UI.get_node("IconSidebar/Thrust/Upgrade").visible = false
	UI.get_node("IconSidebar/Recharge/Upgrade").visible = false

func set_funds(new_funds):
	funds = new_funds
	#cash.text = str(funds)
	UI.get_node("SparesPanel/Amount").text = str(funds)
	print("funds set: ", funds)
	return funds

func get_funds():
	print("funds get: ", funds)
	return funds

func _on_level_loaded(level):
	var ending = level.find_node("Ending")
	print("Level loaded.. Here is the ending: ", ending)


func _on_NextLevel_pressed(event:InputEvent):
	if event.is_action("leftclick") or event.is_action("ui_accept"):
		if int(UI.get_node("IconSidebar/Laser/Amount").text) > 0:
			deactivate()
			get_tree().root.get_node("Robbie").next_level()
		else:
			print("Laser Gun required to move on")

func purchase_item(item_amount:Label):
	var item_name = item_amount.get_parent().name
	print("Attempt to purchase item: ", item_name, " for ", item_prices[item_name])
	print("funds: ", funds)
	if funds >= item_prices[item_name]:
		var player = get_parent().get_node("ActiveLevel/Objects").find_node("Player")
		UI.item_levels[item_name] += 1
		self.funds -= item_prices[item_name]
		player.set_thrusters()
