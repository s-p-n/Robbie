extends Control

export var lives = 3
export var health = 100
export var step = 10

onready var lives_label = $Lives
onready var progress_bar = $ProgressBar

func _ready():
	reset_health()
	publish_changes()

func add_health():
	health += step
	publish_changes()

func remove_health():
	health -= step
	publish_changes()

func reset_health():
	health = 100
	publish_changes()

func add_life():
	lives += 1
	publish_changes()

func remove_life():
	lives -= 1
	if lives <= 0:
		get_parent().game_over()
	publish_changes()

func publish_changes():
	progress_bar.value = health
	lives_label.text = str(lives)
