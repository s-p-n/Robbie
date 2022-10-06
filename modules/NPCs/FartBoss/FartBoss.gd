extends KinematicBody

export var cloudScene:PackedScene

func _on_Butt_body_entered(body):
	if body.name == "Player":
		var cloud = cloudScene.instance()
		cloud.global_transform.origin = global_transform.origin - Vector3(0,1,0)
		get_parent().add_child(cloud)
		print("createdd fart cloud")
