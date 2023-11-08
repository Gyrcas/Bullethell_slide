extends Node
#class_name Global

var player : Player

const auto_target_collision_level : int = 3

func add_debug() -> void:
	var debug : Debug = Debug.new()
	var canvas : CanvasLayer = CanvasLayer.new()
	canvas.add_child(debug)
	get_tree().current_scene.add_child(canvas)

func _ready() -> void:
	add_debug.call_deferred()

func change_scene_to_file(filename : String) -> void:
	get_tree().change_scene_to_file(NodeLinker.request_resource(filename,true))
	add_debug.call_deferred()

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("skip to end"):
		change_scene_to_file("end_demo.tscn")
