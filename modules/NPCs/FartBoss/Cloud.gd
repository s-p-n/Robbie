extends Area

export var damage_interval = 1
export var max_age = 5
var damage_time:float = 0
var time:float = 0
var interactables = []

func _process(delta):
	time += delta
	if interactables.size() > 0:
		damage_time += delta
		if damage_time >= damage_interval:
			damage_time = 0
			for interactable in interactables:
				print("damaging interactable in poo cloud: ", interactable.name)
				interactable.interact()
	if time >= max_age:
		queue_free()
	global_transform.origin.y += 0.01

func _on_Cloud_body_entered(body):
	if body.has_method("interact") and body.name != "FartBoss":
		interactables.append(body)
		if !$FartSound.playing:
			$FartSound.play(0)


func _on_Cloud_body_exited(body):
	if body in interactables:
		interactables.erase(body)
