extends Area

export var damage_interval = 1
export var max_age = 5
var damage_time:float = 0
var time:float = 0
var player = null
var player_in_area = false

func _process(delta):
	time += delta
	if player_in_area:
		damage_time += delta
		if damage_time >= damage_interval:
			damage_time = 0
			player.interact()
	if time >= max_age:
		queue_free()
	global_transform.origin.y += 0.01

func _on_Cloud_body_entered(body):
	if body.has_method("intereact"):
		player = body
		player_in_area = true
		if !$FartSound.playing:
			$FartSound.play(0)


func _on_Cloud_body_exited(body):
	if body.name == "Player":
		player_in_area = false