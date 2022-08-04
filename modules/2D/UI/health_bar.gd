extends Control

export var health = 100
export var step = 10

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

func publish_changes():
	progress_bar.value = health
