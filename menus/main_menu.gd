extends Control

@onready var panel_shader : Panel = $shader

const time_transition : float = 0.3
const force_transition : float = 0.1

var div_disappear : float = 2.0

var disappear : bool = false

func _on_start_pressed() -> void:
	disappear = true


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _process(delta):
	if disappear:
		var previous_opacity : float = panel_shader.material.get_shader_parameter("opacity")
		panel_shader.material.set_shader_parameter("opacity",previous_opacity - delta / div_disappear)
		if previous_opacity <= 0:
			get_tree().change_scene_to_file("res://test.tscn")
	
