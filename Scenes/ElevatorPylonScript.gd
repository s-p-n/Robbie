extends Spatial

export var platform_top:float = 9
export var platform_bottom:float = 1.2
export var platform_brakes:float = 2.5
export var platform_speed:float = 0.5
var is_powered:bool
onready var platform = $Platform
var moving_upwards
var time = 0.0
var time_since = 0.0
var waiting = false
var wait_time = 3.0
var is_working = false
var source = null
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	moving_upwards = true
	is_powered = get_parent().is_powered
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	check_if_working()
	time += delta
	if !waiting:
		check_direction()
	check_power()
	if ((time - time_since) > wait_time) and waiting:
		waiting = false
		change()

	#print("Is_powered: ", is_powered, "\nMoving_upwards: ", moving_upwards, "\nWaiting: ", waiting, "\nTime-Time_since: ", time, "-", time_since)
	if is_powered and is_working:
		if moving_upwards:
			if not waiting:
				platform.transform.origin.y = lerp(platform.transform.origin.y, platform_top + platform_brakes, delta * platform_speed)
		else:
			if not waiting:
				platform.transform.origin.y = lerp(platform.transform.origin.y, platform_bottom - platform_brakes, delta * platform_speed)
	
	#print(platform.transform.origin.y)
	
func change():
	moving_upwards = !moving_upwards

func check_direction():
	if moving_upwards:
		if platform.transform.origin.y >= platform_top:
			waiting = true
			time_since = time
	else:
		if platform.transform.origin.y <= platform_bottom:
			waiting = true
			time_since = time
		
func check_power():
	is_powered = get_parent().is_powered

func check_if_working():
	if !source or !source.is_home:
		source = null
		is_working = false
	
func work(sourcery):
	print("im getting called yo")
	if sourcery:
		source = sourcery
		is_working = true
