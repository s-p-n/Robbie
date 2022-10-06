extends Spatial

export var music:AudioStream
var old_music = null
func _ready():
	var audio_node = get_parent().get_parent().get_node("AudioStreamPlayer")
	old_music = audio_node.stream
	audio_node.stream = music
	audio_node.play(0)
	$FartBoss.connect("boss_dead", self, "_handle_boss_death")

func _exit_tree():
	get_parent().get_parent().get_node("AudioStreamPlayer").stream = old_music


func _handle_boss_death():
	$Room.queue_free()
