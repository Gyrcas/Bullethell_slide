extends Control

@onready var panel_shader : Panel = $shader
@onready var pause_menu : PauseMenu = $pause_menu
@onready var start : Button = $vbox/start

var div_disappear : float = 10.0
const div_appear : float = 50.0

var last_focus : Control

var disappear : bool = false

func _on_start_pressed() -> void:
	AudioPlayer.tween_volume(music_id,-50,2)
	disappear = true
	div_disappear = (0.30 - panel_shader.material.get_shader_parameter("opacity")) * 100



func _on_settings_pressed() -> void:
	last_focus = get_viewport().gui_get_focus_owner()
	pause_menu.open("options")

var audio_player : AudioStreamPlayer

func _ready() -> void:
	start.grab_focus()
	play_music()

var music_id : String

func play_music(_file : String = "") -> void:
	music_id = AudioPlayer.play("musics/ObservingTheStar.ogg",true)
	AudioPlayer.set_audio_process_mode(music_id, PROCESS_MODE_ALWAYS)
	AudioPlayer.set_volume(music_id,-50)
	AudioPlayer.tween_volume(music_id,0,6)
	AudioPlayer.add_callback(music_id, play_music)

func _process(delta):
	var previous_opacity : float = panel_shader.material.get_shader_parameter("opacity")
	if disappear:
		panel_shader.material.set_shader_parameter("opacity",previous_opacity - delta / div_disappear)
		if previous_opacity <= 0:
			Global.change_scene_to_file("intro.tscn")
	elif previous_opacity < 0.25:
		panel_shader.material.set_shader_parameter("opacity",previous_opacity + delta / div_appear)

func _on_load_pressed() -> void:
	last_focus = get_viewport().gui_get_focus_owner()
	pause_menu.open("save_manager",{"back_to_view":"","load_save":true})


func _on_pause_menu_closed() -> void:
	last_focus.grab_focus()
