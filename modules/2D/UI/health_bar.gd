extends Control

export var funds = 0
export var lives = 3
export var health = 100
export var health_step = 10
export var stamina = 100

onready var lives_label = $Lives
onready var health_bar = $HealthBar
onready var stamina_bar = $StaminaBar
onready var recharge = $Recharge

func _ready():
	reset_health()
	publish_changes()

func add_stamina():
	stamina += int(recharge.text)
	publish_changes()

func adjust_stamina(n):
	if n > 0:
		n *= int(recharge.text)
	
	stamina += n
	publish_changes()

func remove_stamina():
	stamina -= 1
	publish_changes()

func add_health():
	health += health_step
	publish_changes()

func remove_health(n = 1):
	health -= health_step * n
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
