extends Control
class_name PauseMenuView

var override_inputs : bool = false

var can_close_with_open_menu : bool = false

var pause_menu : PauseMenu

var last_focus : Control

func on_back_menu() -> void:
	pause_menu.visible = false
	visible = false
	get_tree().paused = false

func _set(property : StringName, value : Variant) -> bool:
	if property == "visible":
		open_close(value)
	return false

func open_close(_opening : bool) -> void:
	pass
