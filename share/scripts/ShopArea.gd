extends Area

onready var objects = find_parent("Objects");


func _on_Area_body_entered(body):
	if body.name != "Player":
		return
		
	var top_node = objects.find_parent("Robbie")
	var audio:AudioStreamPlayer = top_node.get_node("AudioStreamPlayer")
	audio.stop()
	print("shop area entered")


func _on_Area_body_exited(body):
	if body.name != "Player":
		return
	
	var top_node = objects.find_parent("Robbie")
	var audio:AudioStreamPlayer = top_node.get_node("AudioStreamPlayer")
	audio.play(0)
	print("shop area exited")
