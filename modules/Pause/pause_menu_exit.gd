extends Panel

var hover_style = StyleBoxFlat.new()
var hover_color = Color(0.73, 0.62, 0.22, 0.72)

onready var normal_style = $Exit.get_stylebox("normal")

func _ready():
	hover_style.set_bg_color(hover_color)
	
func _on_Exit_gui_input(event):
	if event.is_action("leftclick") and event.is_pressed() and not event.is_echo():
		get_tree().quit()

func _on_focus_entered():
	$Exit.set("custom_styles/normal", hover_style)


func _on_focus_exited():
	$Exit.set("custom_styles/normal", normal_style)
