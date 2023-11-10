extends Node

const auto_save_name : String = "auto save"
var save_location : String = NodeLinker.request_resource("saves",true) + "/"
var save_loaded : bool = false

const base_data : Dictionary = {
	"current_scene" : "cave_crash.tscn",
	"position":"(0,0)",
	"intro" : false
}

var data : Dictionary = base_data

func reset_data() -> void:
	data = base_data

func save(savename : String) -> void:
	data.current_scene = get_tree().current_scene.scene_file_path.get_file()
	FS.write(save_location + savename + ".json",JSON.stringify(data))

func load_save(savename : String) -> void:
	save_loaded = true
	data = JSON.parse_string(FS.read(save_location + savename + ".json"))
	data.merge(base_data)
	get_tree().paused = false
	Global.change_scene_to_file(data.current_scene)

func delete_save(savename : String) -> void:
	FS.delete(save_location + savename + ".json")
