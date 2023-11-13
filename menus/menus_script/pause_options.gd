extends PauseMenuView

@export_file("*.json") var settings_file : String
@onready var inputs : Button = $center/vbox/inputs

func on_back_menu() -> void:
	if pause_menu.views.get_node_or_null("main"):
		pause_menu.change_view("main")
	else:
		pause_menu.visible = false
		get_tree().paused = false


func _on_inputs_pressed() -> void:
	pause_menu.change_view("inputs")

func open_close(opening : bool) -> void:
	if opening:
		inputs.grab_focus()
