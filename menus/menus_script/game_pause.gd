extends PauseMenuView

func _on_resume_pressed() -> void:
	pause_menu.visible = false
	get_tree().paused = false


func _on_options_pressed() -> void:
	pause_menu.change_view("options")


func _on_load_pressed() -> void:
	pause_menu.change_view("save_manager",{"back_to_view":"main","load_save":true})