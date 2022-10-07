extends ItemList

onready var selectAudio = get_parent().get_node("SelectAudio")

var item_prices = {
	"Laser Gun": 5,
	"Recharge II": 10,
	"Wires II": 10,
	"Extra Life": 10,
	"Wings": 25
}

var shop_items = []

func _ready ():
	for iten in shop_items:
		add_item(iten)


func _input (event):
	if event is InputEventJoypadButton and Input.is_action_just_pressed("ui_accept"):
		find_parent("Shop")._on_Buy_pressed()

func _on_ItemList_item_selected(index):
	var iten = get_item_text(index)
	var cost = item_prices[iten]
	get_parent().get_node("Cost").text = str(cost)
	selectAudio.play(0)
