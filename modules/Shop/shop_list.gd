extends ItemList


var shop_items = ["Fat Bitches", "Faygo", "Wickid Killer Axe"]

func _ready ():
	for iten in shop_items:
		add_item(iten)
