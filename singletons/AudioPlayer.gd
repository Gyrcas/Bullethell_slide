extends Node
#class_name AudioPlayer

const audio_folder : String = "res://audio/"

var cache : Dictionary = {}

func tween_volume(audio_player,final_value : float,time : float, callback = null) -> void:
	var tween : Tween = create_tween()
	tween.tween_property(audio_player,"volume_db",final_value,time)
	if callback:
		tween.tween_callback(callback)
	tween.play()

func play(file : String,
		everywhere : bool = true, 
		pos : Vector2 = Vector2.ZERO,
		callback_ready : Callable = (func(_audio):return), 
		callback_end : Callable = (func(_file_played):return)
		) -> void:
	var audio_player : Variant
	if everywhere:
		audio_player = AudioStreamPlayer.new()
	else:
		audio_player = AudioStreamPlayer2D.new()
		audio_player.global_position = pos
	audio_player.autoplay = true
	audio_player.stream = load(audio_folder + file)
	get_tree().current_scene.add_child(audio_player)
	callback_ready.call(audio_player)
	await audio_player.finished
	audio_player.queue_free()
	callback_end.call(file)
	
