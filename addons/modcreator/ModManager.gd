extends Node

var config : Dictionary = {}

func _ready() -> void:
	var file : FileAccess = FileAccess.open("res://addons/ModCreator/config.json", FileAccess.READ)
	config = JSON.parse_string(file.get_as_text())
	var dir : DirAccess = DirAccess.open("res://"+config.mod_folder)
	if !dir:
		return
	config["mods"] = dir.get_directories()
	get_tree().connect("node_added",node_added)

func node_added(node : Node) -> void:
	if node.scene_file_path:
		print(node.scene_file_path)
