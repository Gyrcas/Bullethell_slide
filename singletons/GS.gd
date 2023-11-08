extends Node

const auto_save_name : String = "auto save"
var save_location : String = NodeLinker.request_resource("saves",true) + "/"
var save_loaded : bool = false

var data : Dictionary = {
	"current_scene" : "cave_crash.tscn",
	"position":Vector2.ZERO,
	"intro" : false
}

func save(savename : String) -> void:
	data.current_scene = get_tree().current_scene.scene_file_path.get_file()
	FS.write(save_location + savename + ".json",JSON.stringify(data))

func load_save(savename : String) -> void:
	save_loaded = true
	data = JSON.parse_string(FS.read(save_location + savename + ".json"))
	get_tree().paused = false
	Global.change_scene_to_file(data.current_scene)

func delete_save(savename : String) -> void:
	FS.delete(save_location + savename + ".json")
