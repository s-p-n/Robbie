extends Control

export var funds = 0
export var lives = 3
export var health = 100
export var health_step = 10
export var stamina = 100

export(Dictionary) var item_levels = {
	"Laser": 1,
	"Thrust": 1,
	"Recharge": 1
}


onready var lives_label = $Lives
onready var health_bar = $HealthBar
onready var stamina_bar = $StaminaBar
onready var compass = $Compass

onready var laser_label = $IconSidebar/Laser/Amount
onready var thrust_label = $IconSidebar/Thrust/Amount
onready var recharge_label = $IconSidebar/Recharge/Amount
onready var Shop = get_parent().get_node("Shop")

func _ready():
	reset_health()
	publish_changes()

func add_stamina():
	stamina += item_levels["Recharge"]
	publish_changes()

func adjust_stamina(n):
	if n > 0:
		n *= int(item_levels["Recharge"])
	
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

func increase_item_level(item_name:String):
	item_levels[item_name] += 1
	get_node("IconSidebar/" + item_name + "/Amount").text = str(item_levels[item_name])

func set_laser(new_value):
	item_levels["Laser"] = new_value
	laser_label.text = str(new_value)

func set_thrust(new_value):
	item_levels["Thrust"] = new_value
	thrust_label.text = str(new_value)

func set_recharge(new_value):
	item_levels["Recharge"] = new_value
	recharge_label.text = str(new_value)

func set_compass(degr):
	if len(degr) <= 3:
		degr = degr + '.0000'
	var x = str(degr)[3]
	if x == '.':
		compass.text = str(degr).left(6)
		return
	compass.text = str(degr).left(5)
	return

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
	
	laser_label.text = str(item_levels["Laser"])
	thrust_label.text = str(item_levels["Thrust"])
	recharge_label.text = str(item_levels["Recharge"])


func _on_BatteryUpgrade_pressed():
	pass # Replace with function body.


func _on_LaserUpgrade_pressed():
	Shop.purchase_item(laser_label)
	#laser_level += 1


func _on_ThrustUpgrade_pressed():
	Shop.purchase_item(thrust_label)
	#thrust_level += 1


func _on_RechargeUpgrade_pressed():
	Shop.purchase_item(recharge_label)
	#recharge_level += 1
