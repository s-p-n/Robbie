extends Spatial

onready var brain:Spatial = get_parent()
onready var explore:Spatial = brain.get_node("Explore")
onready var react:Spatial = brain.get_node("React")

func make_decision():
	var sight:Array = explore.discovered_objects
	
	var action = {
		"object": explore,
		"method": "look",
		"args": [],
		"weight": 0.0
	}
	
	
	for entity in sight:
		for interesting_name in brain.interesting_object_names:
			if entity.name == interesting_name:
				print("go towards interesting obj")
				action = pick_action_by_weight(action, react.handle_interesting_in_sight(entity))
				break
			else:
				action = pick_action_by_weight(action, react.handle_obsticle_in_sight(entity))
	
	return brain.queue_action(action)
	
func pick_action_by_weight(a, b):
	if a["weight"] > b["weight"]:
		return a
	return b
