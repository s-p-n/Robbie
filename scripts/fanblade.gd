extends RigidBody
onready var root = get_tree().root
onready var player = root.get_node("Robbie/ActiveLevel").get_child(0).get_node_or_null("Player");

export var speed = 1
var cur_rotation = 0
onready var start_pos = transform.origin
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var blade = self
export var is_spinning = true
# Called when the node enters the scene tree for the first time.
func _ready():
	
	print(root.get_node("Robbie/ActiveLevel").get_child(0))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_spinning:
		cur_rotation = lerp(cur_rotation, 0, delta * speed * 0.1)
	else:
		cur_rotation = delta * speed
	transform.origin = start_pos
	blade.rotate_z(cur_rotation)


func _on_blade_body_entered(body):
	print(player)
	print("hitting something: ", body)
	print(body == player)
	if body == player:
		print("player dead")
		root.get_node("Robbie").restart_level()
	
