extends Spatial

export(Array, AudioStream) var footstep_sounds = []
export var timer_path:NodePath

var timer:Timer
var movement:Node

var move_connection

func set_movement(new_movement):
	movement = new_movement
	timer = get_node_or_null(timer_path)
	move_connection = movement.connect("move_on_floor", self, "handle_footstep")
	print("move_connection: ", move_connection)

func handle_footstep():
	if timer.is_stopped():
		var animation_speed = 1.0 / (movement.player_speed / 2)
		if round(movement.player_speed) > 3:
			play_sound(-20)
		elif round(movement.player_speed) == 3:
			play_sound(-30)
		else:
			play_sound(-40)
		timer.wait_time = animation_speed
		timer.start()
	if !movement.snapped:
		play_sound(-10)

func play_sound(volume): # To avoid the sound from clipping, we generate a new audio node each time then we delete it
	var audio_node = AudioStreamPlayer.new()
	if len(footstep_sounds) == 0:
		return
	var pick_sound = randi() % footstep_sounds.size() # Pick a random sound
	audio_node.stream = footstep_sounds[pick_sound]
	audio_node.volume_db = volume
	audio_node.pitch_scale = rand_range(0.95, 1.05)
	add_child(audio_node)
	audio_node.play()
	yield(get_tree().create_timer(2), "timeout")
	audio_node.queue_free()
