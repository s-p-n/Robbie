extends Spatial

export(Array, AudioStream) var footstep_sounds = []
onready var root = get_tree().get_root()
onready var active_level = root.get_node("Robbie/ActiveLevel").get_child(0)
var player

func _ready():
	if active_level:
		set_player()
	
func _process(_delta):
	if $Timer.is_stopped():
		set_player()
		if !player:
			print("player is falsey")
			return
		if player.is_on_floor() and player.player_speed >= 2:
			var animation_speed = 1.0 / (player.player_speed / 2)
			if round(player.player_speed) > 3:
				play_sound(-20)
			elif round(player.player_speed) == 3:
				play_sound(-30)
			else:
				play_sound(-40)
			$Timer.wait_time = animation_speed
			$Timer.start()
	
	if player.is_on_floor() and player.snapped == false:
		play_sound(-10)

func set_player():
	var active_level = root.get_node("Robbie/ActiveLevel").get_child(0)
	if active_level:
		player = active_level.get_node_or_null("Player")
	else:
		player = null

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
