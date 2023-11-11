extends Node
#class_name AudioPlayer

const audio_folder : String = "res://audio/"

var cache : Dictionary = {}

var group_volume : Dictionary = {
	"default":0
}

var active_audio : Dictionary = {}

func tween_volume(id : String,final_value : float,time : float, callback = null) -> void:
	var tween : Tween = create_tween()
	tween.tween_property(active_audio[id].player,"volume_db",final_value,time)
	if callback:
		tween.tween_callback(callback)
	tween.play()

func add_callback(id : String, callback : Callable) -> void:
	var audio : Dictionary = active_audio[id]
	audio.player.connect("finished",callback.bind(audio.file))

func change_group(id : String, group : String) -> void:
	var audio_player : Node = active_audio[id].player
	audio_player.remove_from_group(audio_player.get_groups()[0])
	add_to_group(group)

func set_volume(id : String, volume_db : float) -> void:
	var audio_player : Node = active_audio[id].player
	audio_player.volume_db = volume_db + group_volume[audio_player.get_groups()[0]]

func set_volume_group(group : String, volume_db : float) -> void:
	for player in get_tree().get_nodes_in_group(group):
		player.volume_db += volume_db - group_volume[group]
	group_volume[group] = volume_db

func set_position(id : String, pos : Vector2) -> void:
	var player : Node = active_audio[id].player
	if player is AudioStreamPlayer2D:
		player.global_position = pos

func play(file : String,everywhere : bool = true) -> String:
	var current_id : int = 0
	while active_audio.has(str(current_id)):
		current_id += 1
	var audio_player : Node
	if everywhere:
		audio_player = AudioStreamPlayer.new()
	else:
		audio_player = AudioStreamPlayer2D.new()
	audio_player.autoplay = true
	audio_player.stream = load(audio_folder + file)
	audio_player.volume_db = group_volume.default
	audio_player.add_to_group("default")
	active_audio[str(current_id)] = {"player":audio_player,"file":file}
	get_tree().current_scene.add_child(audio_player)
	audio_player.connect("finished",delete.bind(str(current_id)))
	audio_player.connect("tree_exiting",delete.bind(str(current_id)))
	return str(current_id)

func delete(id : String) -> void:
	if !active_audio.has(id):
		return
	var audio_player : Variant = active_audio[id].player
	active_audio.erase(id)
	audio_player.queue_free()
