extends OmniLight

export var min_energy:float = 0
export var max_energy:float = 2

var target_energy:float = rand_range(min_energy, max_energy)

var t:float = 0
var flicker_time:float = 1
var throttle_interval:float = 0
var throttle:float = 0

func _process(delta):
	if visible:
		throttle += delta
		if throttle <= throttle_interval:
			return
		flicker(delta + throttle)
		throttle = 0

func flicker(delta):
	t += delta
	if t < flicker_time:
		light_energy = 1
	else:
		if light_energy > 0.1:
			light_energy = lerp(light_energy, 0, delta + 0.25)
		else:
			t = 0
			flicker_time = rand_range(0.5, 5)
