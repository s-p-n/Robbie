extends OmniLight

export var min_energy:float = 0
export var max_energy:float = 2

var target_energy:float = rand_range(min_energy, max_energy)

var t:float = 0
var flicker_time:float = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if visible:
		flicker(delta)

func flicker(delta):
	t += delta
	if t < flicker_time:
		light_energy = 1
		return
	else:
		if light_energy > 0.1:
			light_energy = lerp(light_energy, 0, delta + 0.25)
		else:
			t = 0
			flicker_time = rand_range(0.5, 5)
		return
	#print(light_energy, ' -> ', target_energy)
	if light_energy < target_energy:
		light_energy = lerp(light_energy, target_energy, delta + 0.3)
		if light_energy >= target_energy:
			t = 0
			print(light_energy)
			target_energy = rand_range(min_energy, max_energy)
	elif light_energy > target_energy:
		light_energy = lerp(light_energy, target_energy, delta + 0.3)
		if light_energy <= target_energy:
			t = 0
			print(light_energy)
			target_energy = rand_range(min_energy, max_energy)
	else:
		print(light_energy)
		target_energy = rand_range(min_energy, max_energy)
	
	
