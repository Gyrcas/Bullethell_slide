extends PauseMenuView

func on_back_menu() -> void:
	pause_menu.visible = false
	get_tree().paused = false


func _on_resume_pressed() -> void:
	pause_menu.visible = false
	get_tree().paused = false


func _on_options_pressed() -> void:
	pause_menu.change_view("options")
