extends Node
#class_name Global

var player : Player

const auto_target_collision_level : int = 3

func change_scene_to_file(filename : String) -> void:
	get_tree().change_scene_to_file(NodeLinker.request_resource(filename))
