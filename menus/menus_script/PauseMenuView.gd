extends Control
class_name PauseMenuView

var override_inputs : bool = false

var pause_menu : PauseMenu

func on_back_menu() -> void:
	pause_menu.visible = false
	visible = false
	get_tree().paused = false
