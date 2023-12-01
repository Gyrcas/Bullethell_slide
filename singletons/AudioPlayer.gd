extends Node
#class_name AudioPlayer

const audio_folder : String = "res://audio/"

var active_audio : Dictionary = {}

func tween_volume(id : String,final_value : float,time : float, callback = null) -> void:
	var tween : Tween = create_tween()
	tween.tween_property(active_audio[id].player,"volume_db",final_value,time)
	if callback:
		tween.tween_callback(callback)

func add_callback(id : String, callback : Callable) -> void:
	var audio : Dictionary = active_audio[id]
	audio.player.connect("finished",callback.bind(audio.file))

func set_volume(id : String, volume_db : float) -> void:
	active_audio[id].player.volume_db = volume_db
	

func set_position(id : String, pos : Vector2) -> void:
	var player : Node = active_audio[id].player
	if player is AudioStreamPlayer2D:
		player.global_position = pos

var muted : bool = false : set = set_muted

func set_muted(mute : bool) -> void:
	muted = mute
	for i in AudioServer.bus_count:
		AudioServer.set_bus_mute(i,mute)

func set_pitch(id : String, pitch : float) -> void:
	active_audio[id].player.pitch_scale = pitch

func move_play(id : String,time : float) -> void:
	active_audio[id].player.play(time)

func set_loop(id : String, loop : bool) -> void:
	if loop:
		if active_audio[id].player.is_connected("finished",delete):
			active_audio[id].player.disconnect("finished",delete)
		active_audio[id].player.connect("finished",move_play.bind(id,0))
	else:
		if active_audio[id].player.is_connected("finished",move_play):
			active_audio[id].player.disconnect("finished",move_play)
		active_audio[id].player.connect("finished",delete.bind(id))

func play(file : String,everywhere : bool = true, autoplay : bool = true) -> String:
	var current_id : int = 0
	while active_audio.has(str(current_id)):
		current_id += 1
	var audio_player : Node
	if everywhere:
		audio_player = AudioStreamPlayer.new()
	else:
		audio_player = AudioStreamPlayer2D.new()
	audio_player.autoplay = autoplay
	audio_player.stream = load(audio_folder + file)
	active_audio[str(current_id)] = {"player":audio_player,"file":file}
	get_tree().current_scene.add_child.call_deferred(audio_player)
	audio_player.connect("finished",delete.bind(str(current_id)))
	audio_player.connect("tree_exiting",delete.bind(str(current_id)))
	return str(current_id)

func set_playing_from(id : String, time : float) -> void:
	active_audio[id].player.play(time)

func set_play(id : String, playing : bool) -> void:
	if !active_audio[id].player.is_inside_tree():
		await active_audio[id].player.ready
	if playing:
		active_audio[id].player.play()
	else:
		active_audio[id].player.stop()

func set_bus_by_name(id : String, bus_name : StringName) -> void:
	if AudioServer.get_bus_index(bus_name):
		active_audio[id].player.bus = bus_name

func set_bus_by_id(id : String, bus_id : int) -> void:
	if bus_id < AudioServer.bus_count:
		active_audio[id].player.bus = AudioServer.get_bus_name(bus_id)

func set_audio_process_mode(id : String, audio_process_mode : ProcessMode) -> void:
	active_audio[id].player.process_mode = audio_process_mode

func delete(id : String) -> void:
	if !active_audio.has(id):
		return
	var audio_player : Variant = active_audio[id].player
	active_audio.erase(id)
	audio_player.queue_free()

const pitch_effect_id : int = 0

func set_bus_pitch(pitch : float) -> void:
	AudioServer.get_bus_effect(3,pitch_effect_id).pitch_scale = pitch

func get_bus_pitchs() -> Array[AudioEffectPitchShift]:
	var pitchs : Array[AudioEffectPitchShift] = []
	for bus in AudioServer.bus_count:
		pitchs.append(AudioServer.get_bus_effect(bus,pitch_effect_id))
	return pitchs

func _ready() -> void:
	var settings : Dictionary = JSON.parse_string(FS.read("res://data/settings.json"))
	if !settings.has("volume"):
		return
	for bus in AudioServer.bus_count:
		AudioServer.add_bus_effect(bus,AudioEffectPitchShift.new(),pitch_effect_id)
	for key in settings.volume.keys():
		var bus_id : Variant = AudioServer.get_bus_index(key)
		if bus_id == null:
			continue
		AudioServer.set_bus_volume_db(bus_id,settings.volume[key])
