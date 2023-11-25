extends Node

const mods_folder : String = "mods/"

const settings : String = "settings.json"

var mods : PackedStringArray = []

var active_mods : Array[String] = []

var path : String = "res://" + mods_folder

var root_folder : String = ""

func _ready() -> void:
	if !DirAccess.dir_exists_absolute(path):
		path = (
			OS.get_executable_path().get_base_dir() +
			"/" +
			ProjectSettings.globalize_path(path)
		)
	var dir : DirAccess = DirAccess.open(path)
	if !dir:
		return
	mods = dir.get_directories()
	root_folder = path.replace(mods_folder,"")
	get_tree().connect("node_added",node_added)

func node_added(node : Node) -> void:
	if node.scene_file_path:
		print(node.scene_file_path.replace(root_folder,""))

func save() -> void:
	pass
