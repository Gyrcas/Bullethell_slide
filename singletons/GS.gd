extends Node

const auto_save_name : String = "auto save"
var save_location : String = await NodeLinker.request_resource("saves",true) + "/"
var save_loaded : bool = false

var base_data : Dictionary = {
	"current_scene" : "cave_crash.tscn",
	"position":"(0,0)",
	"datetime":"0"
}

var data : Dictionary = base_data.duplicate()

func reset_data() -> void:
	data = base_data.duplicate()

func save(savename : String) -> String:
	data.datetime = Time.get_datetime_string_from_system(false,true)
	data.current_scene = get_tree().current_scene.scene_file_path.get_file()
	FS.write(save_location + savename + ".json",JSON.stringify(data))
	return save_location + savename + ".json"

func load_save(savename : String) -> void:
	save_loaded = true
	if !FS.is_file(save_location + savename + ".json"):
		Global.change_scene_to_file("main_menu.tscn")
		return
	data = JSON.parse_string(FS.read(save_location + savename + ".json"))
	get_tree().paused = false
	Global.change_scene_to_file(data.current_scene)

func delete_save(savename : String) -> void:
	FS.delete(save_location + savename + ".json")
