extends Spatial

onready var brain:Spatial = get_parent()
onready var decide:Spatial = brain.get_node("Decide")
onready var explore:Spatial = brain.get_node("Explore")

func _ready():
	var result = explore.connect("see", self, "handle_discovery")
	var result2 = explore.connect("stand_on", self, "handle_stand_on_entity")
	if result != OK or result2 != OK:
		print("AI->Reach: Cannot connect signal 'see' from AI->Explore.")

func handle_discovery(entity:Spatial):
	if !is_instance_valid(brain) or !is_instance_valid(entity):
		return
	#print("discovery: ", entity.name)
	if entity.name in brain.interesting_object_names:
		brain.queue_action(handle_interesting_in_sight(entity))
	else:
		brain.queue_action(handle_obsticle_in_sight(entity))

func handle_interesting_in_sight(entity:Spatial):
	#var entity_origin = entity.global_transform.origin
	#var my_origin = global_transform.origin
	#var dist_to_entity = my_origin.distance_to(entity_origin)
	#print("see interesting ", entity.name)
	
	return {
		"object": explore,
		"method": "follow",
		"args": [entity],
		"weight": 0.5
	}

func handle_stand_on_entity(entity:Spatial):
	
	if entity.name == "WireWhole":
		#print("Stand on Wire: ", entity.name)
		brain.queue_action({
			"object": self,
			"method": "interact",
			"args": [entity],
			"weight": 0.7
		})
	elif entity.name == "Input":
		if len(entity.pylon.wires) > 0:
			var powerline = entity.pylon.wires[0]
			var dest = powerline.pair[0]
			if dest == entity:
				dest = powerline.pair[1]
			#print("dest: ", dest)
			brain.queue_action({
				"object": explore,
				"method": "follow",
				"args": [dest],
				"weight": 0.75
			})

func handle_obsticle_in_sight(_entity:Spatial):
	#print("see obstacle ", _entity.name)
	return {
		"object": explore,
		"method": "turn",
		"args": [],
		"weight": 0.1
	}

func within_range(distance:float):
	return distance <= brain.action_distance

func interact(entity:Spatial):
	if is_instance_valid(entity):
		#print("Should interact with: ", entity.name)
		if entity.name == "WireWhole":
			entity.powerline.disconnect_pair()
