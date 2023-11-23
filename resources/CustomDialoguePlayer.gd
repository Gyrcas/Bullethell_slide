@tool
extends DialoguePlayer
class_name CustomDialoguePlayer


func play_sound() -> void:
	var sound_id : String = AudioPlayer.play("sounds/FUI Button Beep Clean.wav",true,false)
	AudioPlayer.set_volume(sound_id, -15)
	AudioPlayer.set_pitch(sound_id,randf_range(0.95,1))
	AudioPlayer.set_bus_by_name(sound_id,"Dialogue")
	AudioPlayer.set_play(sound_id,true)
