extends Node

const mods_folder : String = "mods/"

const settings : String = "settings.json"

var data : Dictionary = {
	"mods":[],
	"active_mods":[]
}

func _ready() -> void:
	var path : String = "res://" + mods_folder
	if !DirAccess.dir_exists_absolute(path):
		path = (
			OS.get_executable_path().get_base_dir() +
			"/" +
			ProjectSettings.globalize_path("res://" + mods_folder)
		)
	var dir : DirAccess = DirAccess.open(path)
	if !dir:
		return
	data.mods = dir.get_directories()
	get_tree().connect("node_added",node_added)

func node_added(node : Node) -> void:
	if node.scene_file_path:
		print(node.scene_file_path)
