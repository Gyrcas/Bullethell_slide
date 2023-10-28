extends Node

var save_location : String = NodeLinker.request_resource("saves",true) + "/"

var data : Dictionary = {
	"current_scene" : "cave_crash.tscn",
	"position":Vector2.ZERO,
	"intro" : false
}

func save(savename : String) -> void:
	data.current_scene = get_tree().current_scene.scene_file_path.get_file()
	FS.write(save_location + savename + ".json",JSON.stringify(data))

func load_save(savename : String) -> void:
	data = JSON.parse_string(FS.read(save_location + savename + ".json"))
	get_tree().change_scene_to_file(NodeLinker.request_resource(data.current_scene))
