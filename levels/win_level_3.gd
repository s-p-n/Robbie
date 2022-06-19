extends RigidBody

onready var scene_manager = get_tree().get_root().get_node("Robbie")
onready var player = get_parent().get_parent().get_node_or_null("Player")

func _on_block441wall20_body_entered(body):
	if body == player:
		scene_manager.load_level('workshop')
