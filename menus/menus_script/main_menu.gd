extends Control

@onready var panel_shader : Panel = $shader
@onready var pause_menu : PauseMenu = $pause_menu
@onready var start : Button = $vbox/start
@onready var vbox : VBoxContainer = $vbox

var last_focus : Control

var starting : bool = false

func _on_start_pressed() -> void:
	if starting:
		return
	starting = true
	AudioPlayer.tween_volume(music_id,-50,2)
	if tween && tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self,"opacity",0,2)
	tween.tween_callback(Global.change_scene_to_file.bind("intro.tscn"))


func _on_settings_pressed() -> void:
	last_focus = get_viewport().gui_get_focus_owner()
	for child in vbox.get_children():
		child.focus_mode = FOCUS_NONE
	pause_menu.open("options")

var audio_player : AudioStreamPlayer

var opacity : float = 0.25 : set = set_opacity

func set_opacity(value : float) -> void:
	opacity = value
	panel_shader.material.set_shader_parameter("opacity",opacity)

var tween : Tween

func _ready() -> void:
	opacity = 0
	start.grab_focus()
	play_music()
	tween = create_tween()
	tween.tween_property(self,"opacity",0.25,10)
	

var music_id : String

func play_music(_file : String = "") -> void:
	music_id = AudioPlayer.play("musics/ObservingTheStar.ogg",true)
	AudioPlayer.set_bus_by_name(music_id,"Music")
	AudioPlayer.set_audio_process_mode(music_id, PROCESS_MODE_ALWAYS)
	#AudioPlayer.set_volume(music_id,-50)
	#AudioPlayer.tween_volume(music_id,0,6)
	AudioPlayer.add_callback(music_id, play_music)

func _on_load_pressed() -> void:
	last_focus = get_viewport().gui_get_focus_owner()
	for child in vbox.get_children():
		child.focus_mode = FOCUS_NONE
	pause_menu.open("save_manager",{"back_to_view":"","load_save":true})


func _on_pause_menu_closed() -> void:
	for child in vbox.get_children():
		child.focus_mode = FOCUS_ALL
	last_focus.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)


func _on_mods_pressed() -> void:
	last_focus = get_viewport().gui_get_focus_owner()
	for child in vbox.get_children():
		child.focus_mode = FOCUS_NONE
	pause_menu.open("mod_menu",{"back_to_view":""})
