extends ItemList

var item_prices = {
	"Laser Gun": 5,
	"Battery II": 10,
	"Wires II": 10,
	"Extra Life": 10,
	"Wings": 25
}

var shop_items = []

func _ready ():
	for iten in shop_items:
		add_item(iten)


func _on_ItemList_item_selected(index):
	var iten = get_item_text(index)
	var cost = item_prices[iten]
	get_parent().get_node("Cost").text = str(cost)
	
