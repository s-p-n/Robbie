extends ItemList

var item_prices = {
	"Laser Gun": 5
}

var shop_items = ["Laser Gun"]

func _ready ():
	for iten in shop_items:
		add_item(iten)


func _on_ItemList_item_selected(index):
	var iten = get_item_text(index)
	var cost = item_prices[iten]
	print(iten, " costs ", cost)
	
