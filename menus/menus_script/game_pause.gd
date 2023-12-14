extends PauseMenuView

@onready var resume : Button = $center/vbox/resume

func _init() -> void:
	can_close_with_open_menu = true

func _on_resume_pressed() -> void:
	pause_menu.visible = false
	get_tree().paused = false

func _on_options_pressed() -> void:
	last_focus = get_viewport().gui_get_focus_owner()
	pause_menu.change_view("options")


func _on_load_pressed() -> void:
	last_focus = get_viewport().gui_get_focus_owner()
	pause_menu.change_view("save_manager",{"back_to_view":"main","load_save":true})


func _on_quit_pressed() -> void:
	get_tree().paused = false
	Global.change_scene_to_file("main_menu.tscn")

func open_close(opening : bool) -> void:
	if opening:
		resume.grab_focus()
