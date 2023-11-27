extends Node
#class_name Global

var player : Player

const auto_target_collision_level : int = 3

var bullet_script : Dictionary = {
	"default":Bullet.new().get_script(),
	"bomb":Bomb.new().get_script()
}

var storage : Dictionary = {}

var debug_open : bool = false
var debug_pos : Vector2 = Vector2.ZERO

const time_pitch_div : float = 5
const time_tween_mult : float = 2

func set_time_scale(time_scale : float, change_sound : bool = true) -> void:
	Engine.time_scale = time_scale
	if change_sound:
		AudioPlayer.set_bus_pitch(1 - (1 - time_scale) / time_pitch_div)

func tween_time_scale(final_scale : float,time : float, tween_sound : bool = true) -> void:
	var tween : Tween = create_tween()
	tween.parallel().tween_property(Engine,"time_scale",final_scale,time)
	if !tween_sound:
		return
	var pitchs : Array[AudioEffectPitchShift] = AudioPlayer.get_bus_pitchs()
	var pitch_value : float = 1 - (1 - final_scale) / time_pitch_div
	time *= time_tween_mult
	tween.parallel().tween_property(pitchs[3],"pitch_scale",pitch_value,time)

func add_debug() -> void:
	var debug : Debug = Debug.new()
	var canvas : CanvasLayer = CanvasLayer.new()
	canvas.add_child(debug)
	get_tree().current_scene.add_child(canvas)
	debug.visible = debug_open
	debug.global_position = debug_pos

func _ready() -> void:
	add_debug.call_deferred()
	var settings : Dictionary = JSON.parse_string(FS.read(
		NodeLinker.request_resource("settings.json",true)
	))
	if !settings.has("window_type"):
		settings["window_type"] = 0
	match int(settings.window_type):
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

# Made longer because caused unknown crash before
func change_scene_to_file(filename : String, mod : String = "") -> void:
	var path : String = ""
	if mod != "":
		path = FS.root_dir() + NodeLinker.mod_folder + mod + "/" + filename
	else:
		path = NodeLinker.request_resource(filename,true)
	if !FS.is_file(path):
		push_error(path + " is not a file")
		return
	var scene : PackedScene = load(path)
	var tree : SceneTree = get_tree()
	tree.change_scene_to_packed(scene)
	add_debug.call_deferred()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("skip_to_end"):
		change_scene_to_file("end_demo.tscn")
	elif event.is_action_pressed("mute"):
		AudioPlayer.muted = !AudioPlayer.muted

func play_dialogue_player(filename : String, variables : Dictionary = {}, give_control_back : bool = true) -> void:
	var tween : Tween = create_tween()
	tween.tween_property(player,"velocity",Vector2.ZERO,1)
	player.controllable = false
	player.dialogue.variables = variables
	player.dialogue.play(NodeLinker.request_resource(filename,true))
	await player.dialogue.finished
	await get_tree().create_timer(0.1).timeout
	if give_control_back:
		player.controllable = true

var shaking_cameras : Dictionary = {}

func stop_shake_camera(camera : Camera2D) -> void:
	if shaking_cameras[camera]:
		shaking_cameras[camera].active = false

func shake_camera(
		camera : Camera2D,
		cam_range : Vector2, 
		nb_shake : int, 
		speed : float, 
		base_pos : Vector2 = Vector2.ZERO,
		callback : Callable = func():pass
		) -> void:
	var tween : Tween = create_tween()
	if nb_shake == 0 || (shaking_cameras.get(camera) && !shaking_cameras[camera].active):
		shaking_cameras[camera] = null
		tween.tween_property(camera,"position",base_pos,speed)
		tween.tween_callback(callback)
	else:
		tween.tween_property(
			camera,
			"position",
			base_pos + Vector2(
				randf_range(-cam_range.x,cam_range.x),
				randf_range(-cam_range.y,cam_range.y)
			),
			speed
		)
		tween.tween_callback(
			shake_camera.bind(camera,cam_range,nb_shake-1,speed,base_pos,callback)
		)
		shaking_cameras[camera] = {"tween":tween,"active":true}

func get_actions_as_text(action : String) -> String:
	if !InputMap.has_action(action):
		return ""
	var events : Array[InputEvent] = InputMap.action_get_events(action)
	if events.size() == 0:
		return ""
	return events[0].as_text()
