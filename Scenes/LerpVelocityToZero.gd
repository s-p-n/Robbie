extends RigidBody

signal power_obtained(partner)
signal power_lost(partner)

export var is_source:bool

onready var power_light = $PowerLight
onready var audio = get_node_or_null("play_when_powered")

var partners = []
var wires = []

var is_powered = false
var obtained_power_from = null

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
		partner.connect("power_lost", self, "update_power_status")
		partner.connect("power_obtained", self, "update_power_status")
		update_power_status()
	else:
		powerline.destroy()
		
func disconnect_wire_from(powerline, partner):
	if partner in partners:
		partners.erase(partner)
		partner.disconnect("power_lost", self, "update_power_status")
		partner.disconnect("power_obtained", self, "update_power_status")
		wires.erase(powerline)
		if is_instance_valid(powerline):
			powerline.destroy()
			
		update_power_status()


func update_power_status():
	var power_status = is_powered
	var source = deep_search_for_source([self])
	is_powered = is_instance_valid(source)
	if is_powered != power_status:
		if is_powered:
			obtain_power_from(source)
			emit_signal("power_obtained")
			
		else:
			emit_signal("power_lost")
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
	if is_instance_valid(partner) and partner.has_signal("power_lost"):
		if !partner.is_connected("power_lost", self, "update_power_status"):
			partner.connect("power_lost", self, "update_power_status")
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
