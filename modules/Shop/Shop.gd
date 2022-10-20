extends Control

export var funds = 0 setget set_funds, get_funds

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

export var exit_timer:float = 1.0

var hover_theme = preload("res://share/themes/big_button_hover.tres")
var regular_theme = preload("res://share/themes/big_button.tres")

var time:float = 1.0
var active = false

func _ready():
	if get_parent().connect("level_loaded", self, "_on_level_loaded") != OK:
		print("HEY! Couldn't connect shop to level_loaded signal!")
	set_funds(funds)
	
	for item in item_prices:
		var price = item_prices[item]
		get_node("Panel/" + item + "/price").text = str(price)

func _process(delta):
	if !active:
		if time < exit_timer:
			time += delta
	else:
		time = 0
		

func activate():
	if time < exit_timer:
		return
	active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	visible = true
	
	if !is_instance_valid(UI):
		UI = get_parent().get_node("UI")

func deactivate():
	active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	
	if !is_instance_valid(UI):
		UI = get_parent().get_node("UI")

func set_funds(new_funds):
	funds = new_funds
	#cash.text = str(funds)
	if is_instance_valid(UI):
		UI.get_node("SparesPanel/Amount").text = str(funds)
	#print("funds set: ", funds)
	return funds

func get_funds():
	#print("funds get: ", funds)
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
	print("Attempt to purchase item: ", item_name)
	print("Price: ", item_prices[item_name])
	print("funds: ", funds)
	if funds >= item_prices[item_name]:
		var player = get_parent().get_node("ActiveLevel/Objects").find_node("Player")
		UI.increase_item_level(item_name)
		self.funds -= item_prices[item_name]
		player.setup_items()


func _on_Exit_gui_input(event:InputEvent):
	if event.is_action("leftclick") or event.is_action("ui_accept"):
		deactivate()


func _on_NextLevel_mouse_entered():
	$NextLevel.theme = hover_theme


func _on_NextLevel_mouse_exited():
	$NextLevel.theme = regular_theme



func _on_Exit_mouse_entered():
	$ExitShop.theme = hover_theme


func _on_Exit_mouse_exited():
	$ExitShop.theme = regular_theme


func _on_LaserUpgrade_pressed():
	purchase_item(UI.laser_label)


func _on_RechargeUpgrade_pressed():
	purchase_item(UI.recharge_label)


func _on_ThrustUpgrade_pressed():
	purchase_item(UI.thrust_label)


func _on_ExtraLife_pressed():
	purchase_item(UI.lives_label)
