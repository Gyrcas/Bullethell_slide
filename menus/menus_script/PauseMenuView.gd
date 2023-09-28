extends Control
class_name PauseMenuView

var override_inputs : bool = false

var pause_menu : PauseMenu

func _ready() -> void:
	visible = false

func on_back_menu() -> void:
	visible = false
	pause_menu.visible = false
