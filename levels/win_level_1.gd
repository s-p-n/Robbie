extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var scene_manager = get_tree().get_root().get_node("Robbie")
onready var player = get_parent().get_parent().get_node_or_null("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_block441wall39_body_entered(body):
	if body == player:
		scene_manager.load_level('level2')
