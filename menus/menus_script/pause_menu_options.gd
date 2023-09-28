extends PauseMenuView

func on_back_menu() -> void:
	pause_menu.change_view("main")


func _on_inputs_pressed() -> void:
	pause_menu.change_view("inputs")
