extends Label

var hover_style = StyleBoxFlat.new()
var hover_color = Color(0.73, 0.62, 0.22, 0.72)

onready var normal_style = get_stylebox("normal")

func _ready():
	hover_style.set_bg_color(hover_color)
	grab_focus()

func _on_Continue_gui_input(event):
	if event.is_action("leftclick") and event.is_pressed() and not event.is_echo():
		find_parent("Paused").toggle_pause()

func _on_focus_entered():
	print("continue button gained focus")
	set("custom_styles/normal", hover_style)


func _on_focus_exited():
	print("continue button lost focus")
	set("custom_styles/normal", normal_style)

