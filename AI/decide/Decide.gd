extends Spatial

onready var brain:Spatial = get_parent()
onready var explore:Spatial = brain.get_node("Explore")
onready var react:Spatial = brain.get_node("React")

func make_decision():
	var behaviors = brain.behaviors
	
	if behaviors["Explore"]:
		return brain.queue_action({
			"object": explore,
			"method": "move_forward",
			"args": [],
			"weight": 0.0
		})
	
	if behaviors["Hover"]:
		return brain.queue_action({
			"object": explore,
			"method": "hover",
			"args": [],
			"weight": 0.0
		})
	

func pick_action_by_weight(a, b):
	if a["weight"] > b["weight"]:
		return a
	return b
