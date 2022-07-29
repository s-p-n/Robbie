extends Spatial

onready var brain:Spatial = get_parent()
onready var decide:Spatial = brain.get_node("Decide")
onready var explore:Spatial = brain.get_node("Explore")

func _ready():
	var result = explore.connect("see", self, "handle_discovery")
	if result != OK:
		print("AI->Reach: Cannot connect signal 'see' from AI->Explore.")

func handle_discovery(entity:Spatial):
	if !is_instance_valid(brain) or !is_instance_valid(entity):
		return
	if entity.name in brain.interesting_object_names:
		#print("interesting discovery: ", entity)
		brain.queue_action(handle_interesting_in_sight(entity))
	else:
		brain.queue_action(handle_obsticle_in_sight(entity))

func handle_interesting_in_sight(entity:Spatial):
	var entity_origin = entity.global_transform.origin
	var my_origin = global_transform.origin
	var dist_to_entity = my_origin.distance_to(entity_origin)
	
	if within_range(dist_to_entity):
		return {
			"object": self,
			"method": "interact",
			"args": [entity_origin],
			"weight": 0.7
		}
	
	return {
		"object": explore,
		"method": "follow",
		"args": [entity],
		"weight": 0.5
	}

func handle_obsticle_in_sight(_entity:Spatial):
	return {
		"object": explore,
		"method": "turn",
		"args": [],
		"weight": 0.1
	}

func within_range(distance:float):
	return distance <= brain.action_distance

func interact(entity:Spatial):
	print("Should interact with: ", entity)
