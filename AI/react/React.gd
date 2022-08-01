extends Spatial

export var PowerlineScene:PackedScene = null
var powerline = null

onready var brain:Spatial = get_parent()
onready var decide:Spatial = brain.get_node("Decide")
onready var explore:Spatial = brain.get_node("Explore")

func _ready():
	var result = explore.connect("see", self, "handle_discovery")
	var result2 = explore.connect("stand_on", self, "handle_stand_on_entity")
	if result != OK or result2 != OK:
		print("AI->Reach: Cannot connect signal 'see' from AI->Explore.")

func handle_discovery(entity:Spatial, position:Vector3):
	if !is_instance_valid(brain) or !is_instance_valid(entity):
		return
	#print("discovery: ", entity.name)
	var _name = get_name_of_entity(entity)
	var dist = global_transform.origin.distance_to(position)
	if _name in brain.interact_with_object_names and within_range(dist):
		brain.queue_action({
			"object": self,
			"method": "interact",
			"args": [entity],
			"weight": 0.7
		})
	elif _name in brain.seek_out_object_names:
		handle_interesting_in_sight(entity)
	else:
		handle_obstacle_in_sight(entity)

func handle_interesting_in_sight(entity:Spatial):
	var entity_brain = entity.get_node_or_null("Brain")
	if is_instance_valid(entity_brain):
		print("trying to follow something with a brain:")
		print(entity)
		print(entity_brain)
		var entity_explore = entity_brain.get_node_or_null("Explore")
		if is_instance_valid(entity_explore):
			if entity_explore.follow_entity == self:
				print("Not following because being followed by them.")
				return
		
	brain.queue_action({
		"object": explore,
		"method": "follow",
		"args": [entity],
		"weight": 0.5
	})

func handle_stand_on_entity(entity:Spatial):
	var _name = get_name_of_entity(entity)
	if _name in brain.interact_with_object_names:
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
			brain.queue_action({
				"object": explore,
				"method": "follow",
				"args": [dest],
				"weight": 0.75
			})

func handle_obstacle_in_sight(_entity:Spatial):
	brain.queue_action({
		"object": explore,
		"method": "turn",
		"args": [],
		"weight": 0.1
	})

func within_range(distance:float):
	return distance <= brain.action_distance

func get_name_of_entity(entity:Spatial):
	return entity.name.replace(str(entity.name.to_int()), "")

func interact(entity:Spatial):
	if is_instance_valid(entity):
		var _name = get_name_of_entity(entity)
		print("Should interact with: ", _name)
		
		if _name == "Input":
			handle_wire_action(entity)
		else:
			entity.interact()

func handle_wire_action(input:RigidBody):
	if input:
		# Handle: Click wirable obj
		if is_instance_valid(powerline):
			# Handle: Click wirable obj while holding a wire
			if input == powerline.pair[0]:
				# Handle: Click on the same obj that gave us the wire we're holding
				#powerline.destroy()
				return true
			else: 
				# Handle: Click on something wirable, but different than what we're holding
				powerline.end(input)
				powerline = null
				return true
		else:
			# Handle: Click wirable area, but we aren't holding a wire
			powerline = PowerlineScene.instance()
			powerline.set_interact(brain)
			powerline.begin(input)
			#wire_place_audio.play(0.0)
			return true
	else:
		# Handle: Clicked, but not on something wirable
		if is_instance_valid(powerline):
			powerline.destroy()
			return true
	return false
