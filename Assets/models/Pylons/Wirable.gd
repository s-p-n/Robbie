extends RigidBody

signal activated(obj)
signal deactivated(obj)

export var is_source:bool

onready var power_light = $PowerLight
onready var audio = get_node_or_null("play_when_powered")

var partners = []
var wires = []

var is_powered = false
var obtained_power_from = null

var connected_node:Node

func _ready():
	if is_source:
		is_powered = true
	else:
		is_powered = false
	set_visuals()

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
		partners.erase(partner)
		partner.disconnect("deactivated", self, "update_power_status")
		partner.disconnect("activated", self, "update_power_status")
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
		power_light.visible = true
	else:
		if audio and audio.loop:
			audio.stop_stream()
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
