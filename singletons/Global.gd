extends Node
#class_name Global

var player : Player

const auto_target_collision_level : int = 3

var bullet_script : Dictionary = {
	"default":Bullet.new().get_script(),
	"bomb":Bomb.new().get_script()
}

var debug_open : bool = false
var debug_pos : Vector2 = Vector2.ZERO

func add_debug() -> void:
	var debug : Debug = Debug.new()
	var canvas : CanvasLayer = CanvasLayer.new()
	canvas.add_child(debug)
	get_tree().current_scene.add_child(canvas)
	debug.visible = debug_open
	debug.global_position = debug_pos

func _ready() -> void:
	add_debug.call_deferred()

func change_scene_to_file(filename : String) -> void:
	get_tree().change_scene_to_file(NodeLinker.request_resource(filename,true))
	add_debug.call_deferred()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("skip_to_end"):
		change_scene_to_file("end_demo.tscn")
	elif event.is_action_pressed("mute"):
		AudioPlayer.muted = !AudioPlayer.muted
