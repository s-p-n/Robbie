extends Control

export var lives = 3
export var health = 100
export var health_step = 10
export var stamina = 100
export var stamina_step = 1

onready var lives_label = $Lives
onready var health_bar = $HealthBar
onready var stamina_bar = $StaminaBar

func _ready():
	reset_health()
	publish_changes()

func add_stamina():
	stamina += stamina_step
	publish_changes()

func adjust_stamina(n):
	stamina += n
	publish_changes()

func remove_stamina():
	stamina -= stamina_step
	publish_changes()

func add_health():
	health += health_step
	publish_changes()

func remove_health():
	health -= health_step
	publish_changes()

func reset_health():
	health = 100
	publish_changes()
	
func reset_stamina():
	stamina = 100
	publish_changes()

func add_life():
	lives += 1
	publish_changes()

func remove_life():
	lives -= 1
	if lives < 0:
		get_parent().game_over()
	publish_changes()

func publish_changes():
	if health > 100:
		health = 100
	elif health < 0:
		health = 0
	
	if stamina > 100:
		stamina = 100
	elif stamina < 0:
		stamina = 0
	
	health_bar.value = health
	stamina_bar.value = stamina
	lives_label.text = str(lives)
