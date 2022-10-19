extends Sprite

export(Array,Texture) var images

onready var UI = get_parent().get_parent()
onready var Amount = $Amount

func _process(_delta):
	if is_instance_valid(UI):
		var stamina = UI.get_node("StaminaBar").value
		Amount.text = str(stamina)
		var image_count = images.size() - 1
		var image_index:int = int((stamina / 100) * image_count)
		if image_index >= 0 and image_index <= image_count:
			texture = images[image_index]
