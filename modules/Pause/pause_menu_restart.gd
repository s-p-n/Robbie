extends Label

var hover_style = StyleBoxFlat.new()
var hover_color = Color(0.73, 0.62, 0.22, 0.72)

onready var normal_style = get_stylebox("normal")

func _ready():
	hover_style.set_bg_color(hover_color)

func _on_Restart_gui_input(event):
	if (event.is_action("leftclick") or event.is_action("ui_accept")) and event.is_pressed() and not event.is_echo():
		find_parent("Robbie").get_node("ActiveLevel").get_child(0).find_node("Player").respawn()


func _on_focus_entered():
	set("custom_styles/normal", hover_style)


func _on_focus_exited():
	set("custom_styles/normal", normal_style)
