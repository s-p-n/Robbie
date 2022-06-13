extends Spatial
var time
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	time = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if (time > 0.1) and $CPUParticles.emitting == false:
		print(global_transform)
		$CPUParticles.emitting = true
	if time > 1:
		queue_free()


	
