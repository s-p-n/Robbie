extends Sprite

export(Array,Texture) var images

onready var Interact = get_parent()
onready var Amount = $Amount

func _process(_delta):
	if is_instance_valid(Interact.player) and is_instance_valid(Interact.player.UI):
		var UI = Interact.player.UI
		var stamina = UI.get_node("StaminaBar").value
		Amount.text = str(stamina)
		var image_count = images.size() - 1
		var image_index:int = int((stamina / 100) * image_count)
		if image_index >= 0 and image_index <= image_count:
			texture = images[image_index]
