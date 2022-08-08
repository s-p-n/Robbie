extends Spatial

export var PowerlineScene:PackedScene = null
var powerline = null
var fire_lazer = false

onready var brain:Spatial = get_parent()
onready var decide:Spatial = brain.get_node("Decide")
onready var explore:Spatial = brain.get_node("Explore")

func _ready():
	var result = explore.connect("see", self, "handle_discovery")
	var result2 = explore.connect("stand_on", self, "handle_stand_on_entity")
	if result != OK or result2 != OK:
		print("AI->Reach: Cannot connect signal 'see' from AI->Explore.")

func _process(_delta):
	if brain.lazer_state and fire_lazer:
		#print("fire!")
		turn_lazer_on()
		fire_lazer = false
	elif !brain.lazer_state:
		turn_lazer_off()

func handle_discovery(entity:Spatial, position:Vector3):
	if !is_instance_valid(brain) or !is_instance_valid(entity):
		return
	var _name = get_name_of_entity(entity)

	var dist = global_transform.origin.distance_to(position)
	if _name in brain.interact_with_object_names and within_range(dist):
		if _name == "Input":
			brain.queue_action({
				"object": self,
				"method": "handle_wire_action",
				"args": [entity],
				"weight": 0.75
			})
		elif !fire_lazer:
			brain.queue_action({
				"object": self,
				"method": "handle_shoot_at",
				"args": [entity],
				"weight": 0.95
			})
	
	if _name in brain.seek_out_object_names:
		#print("Interesting: ", entity)
		handle_interesting_in_sight(entity)
	else:
		#print("Not Interesting: ", entity)
		handle_obstacle_in_sight(entity)

func handle_interesting_in_sight(entity:Spatial):
	var entity_brain = entity.get_node_or_null("Brain")
	var _name = get_name_of_entity(entity)
	if is_instance_valid(entity_brain) and _name == get_name_of_entity(brain.get_parent()):
		#print("trying to follow something with a brain:")
		#print(entity)
		#print(entity_brain)
		var entity_explore = entity_brain.get_node_or_null("Explore")
		if is_instance_valid(entity_explore):
			if entity_explore.follow_entity == brain.get_parent():
				#print("Not following because being followed by ", entity)
				return
	var weight = 0.5
	if _name == "Player":
		#print("see player")
		weight = 0.75
		
	brain.queue_action({
		"object": explore,
		"method": "follow",
		"args": [entity],
		"weight": weight
	})

func handle_stand_on_entity(entity:Spatial):
	var _name = get_name_of_entity(entity)
	if _name in brain.interact_with_object_names:
		
		print("Standing on interactable: ", entity)
		brain.queue_action({
			"object": self,
			"method": "interact",
			"args": [entity],
			"weight": 0.7
		})
	elif entity.name == "Input":
		if len(entity.pylon.wires) > 0:
			var local_powerline = entity.pylon.wires[0]
			var dest = local_powerline.pair[0]
			
			if dest == entity:
				dest = local_powerline.pair[1]
			
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
	if is_instance_valid(entity):
		return entity.name.replace(str(entity.name.to_int()), "")
	return ""

func interact(entity:Spatial):
	if is_instance_valid(entity):
		var _name = get_name_of_entity(entity)
		#print("Should interact with: ", _name)
		
		if _name == "Input":
			handle_wire_action(entity)
		

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
			return true
	else:
		# Handle: Clicked, but not on something wirable
		if is_instance_valid(powerline):
			powerline.destroy()
			return true
	return false

func handle_shoot_at(entity:Spatial):
	var entity_name = get_name_of_entity(entity)
	print("Should shoot at: ", entity_name)
	explore.follow(entity)
	fire_lazer = true

func turn_lazer_on():
	var beam = brain.get_parent().find_node("LazerBeam")
	if is_instance_valid(beam):
		beam.turn_on()

func turn_lazer_off():
	var beam = brain.get_parent().find_node("LazerBeam")
	if is_instance_valid(beam):
		beam.turn_off()
