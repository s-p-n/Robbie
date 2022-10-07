extends RigidBody

onready var objects = find_parent("Objects")
onready var player = objects.find_node("Player")

func _on_platform15_body_entered(body):
	if !is_instance_valid(objects):
		return
	
	if !is_instance_valid(player):
		player = objects.find_node("Player")
	
	if body == player:
		get_tree().root.get_node("Robbie").next_level()
