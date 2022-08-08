extends RigidBody

signal activated(obj)
signal deactivated(obj)

export var is_source:bool

export var input_color:Color
export var output_color:Color

onready var power_light = $PowerLight
onready var audio = get_node_or_null("play_when_powered")
onready var inputMesh:MeshInstance = get_node_or_null("Input/MeshInstance")

var partners = []
var wires = []

var material:SpatialMaterial = SpatialMaterial.new()

var is_powered = false
var obtained_power_from = null

var connected_node:Node

func _ready():
	inputMesh.set_surface_material(0, material)
	material.albedo_color = input_color
	material.emission = input_color
	power_light.light_color = output_color
	if is_source:
		is_powered = true
	else:
		is_powered = false
	set_visuals()

func _process(_delta):
	if is_instance_valid(connected_node):
		is_source = connected_node.is_powered
		update_power_status(self)
		
func set_power_source(source):
	connected_node = source
	is_source = true
	update_power_status(self)

func unset_power_source():
	connected_node = null
	is_source = false
	update_power_status(self)

func connect_wire_to(powerline, partner):
	if !(partner in partners):
		partners.append(partner)
		wires.append(powerline)
		if !partner.is_connected("deactivated", self, "update_power_status"):
			partner.connect("deactivated", self, "update_power_status")
			partner.connect("activated", self, "update_power_status")
		update_power_status(self)
	else:
		powerline.destroy()

func disconnect_wire_from(powerline, partner):
	if partner in partners:
		partner.disconnect("deactivated", self, "update_power_status")
		if partner.is_connected("activated", self, "update_power_status"):
			partner.disconnect("activated", self, "update_power_status")
		partners.erase(partner)
		wires.erase(powerline)
		if is_instance_valid(powerline):
			powerline.destroy()
			
		update_power_status(self)


func update_power_status(_partner):
	var power_status = is_powered
	var source = deep_search_for_source([self])
	is_powered = is_instance_valid(source)
	if is_powered != power_status:
		if is_powered:
			obtain_power_from(source)
			emit_signal("activated", self)
			#print("wirable activated")
			
		else:
			emit_signal("deactivated", self)
			#print("wirable deactivated")
	set_visuals()

func set_visuals():
	if is_powered:
		if audio and !audio.loop:
			audio.play_stream()
		material.emission_enabled = true
		power_light.visible = true
	else:
		if audio and audio.loop:
			audio.stop_stream()
		material.emission_enabled = false
		power_light.visible = false

func obtain_power_from(partner):
	if is_instance_valid(partner) and partner.has_signal("deactivated"):
		if !partner.is_connected("deactivated", self, "update_power_status"):
			partner.connect("deactivated", self, "update_power_status")
			obtained_power_from = partner

func deep_search_for_source(ignore):
	if is_source:
		return self
	if !(self in ignore):
		ignore.append(self)
	for partner in partners:
		if !(partner in ignore):
			ignore.append(partner)
		else:
			continue
		var result = partner.deep_search_for_source(ignore)
		if result:
			return result
	return null
