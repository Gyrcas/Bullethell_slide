extends Control

@onready var panel_shader : Panel = $shader
@onready var pause_menu : PauseMenu = $pause_menu

var div_disappear : float = 10.0
const div_appear : float = 50.0

var disappear : bool = false

func _on_start_pressed() -> void:
	AudioPlayer.tween_volume(audio_player,-50,2)
	disappear = true
	div_disappear = (0.30 - panel_shader.material.get_shader_parameter("opacity")) * 100


func _on_settings_pressed() -> void:
	pause_menu.open("options")

var audio_player : AudioStreamPlayer

func _ready() -> void:
	play_music()

func play_music() -> void:
	AudioPlayer.play(
		"musics/ObservingTheStar.ogg",
		true,Vector2.ZERO,get_music,play_music)

func get_music(audio) -> void:
	audio_player = audio



func _process(delta):
	var previous_opacity : float = panel_shader.material.get_shader_parameter("opacity")
	if disappear:
		panel_shader.material.set_shader_parameter("opacity",previous_opacity - delta / div_disappear)
		if previous_opacity <= 0:
			Global.change_scene_to_file("intro.tscn")
	elif previous_opacity < 0.25:
		panel_shader.material.set_shader_parameter("opacity",previous_opacity + delta / div_appear)


func _on_load_pressed() -> void:
	pause_menu.open("save_manager",{"back_to_view":"","load_save":true})
