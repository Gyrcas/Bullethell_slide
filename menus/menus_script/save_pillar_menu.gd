extends PauseMenuView

var save_position : Vector2 = Vector2.ZERO : set = set_save_position

func set_save_position(value : Vector2) -> void:
	save_position = value
	GS.data.position = var_to_str(value)
	GS.save(GS.auto_save_name)

func _on_save_pressed() -> void:
	pause_menu.change_view("save_manager",{"back_to_view":"save_pillar_menu","load_save":false,"save_position":save_position})
