extends Control

@onready var panel_shader : Panel = $shader

var div_disappear : float = 10.0
const div_appear : float = 50.0

var disappear : bool = false

func _on_start_pressed() -> void:
	disappear = true
	div_disappear = (0.30 - panel_shader.material.get_shader_parameter("opacity")) * 100


func _on_settings_pressed() -> void:
	$pause_menu.visible = true
	$pause_menu.current_view.visible = true
	get_tree().paused = true


func _process(delta):
	var previous_opacity : float = panel_shader.material.get_shader_parameter("opacity")
	if disappear:
		panel_shader.material.set_shader_parameter("opacity",previous_opacity - delta / div_disappear)
		if previous_opacity <= 0:
			get_tree().change_scene_to_file("res://levels/intro.tscn")
	elif previous_opacity < 0.25:
		panel_shader.material.set_shader_parameter("opacity",previous_opacity + delta / div_appear)


func _on_load_pressed() -> void:
	pass # Replace with function body.
