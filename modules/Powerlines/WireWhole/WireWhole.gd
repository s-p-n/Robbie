extends RigidBody

onready var powerline = get_parent()

func _on_WireWhole_body_entered(body):
	var pylons = [powerline.pair[0].pylon, powerline.pair[1].pylon]
	if !(body in pylons or body == powerline.player):
		print("collided with: ", body)
		print(pylons)
		powerline.disconnect_pair()
