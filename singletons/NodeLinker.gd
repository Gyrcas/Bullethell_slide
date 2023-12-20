extends Node

var save_file : String = "res://resources/nodelinker_data.json"

var data : Dictionary = {}

var is_data_loaded : bool = false

signal data_loaded

func load_data_file() -> void:
	data = JSON.parse_string(FS.read(save_file))
	var dup : Dictionary = data.duplicate()
	for key in data.keys():
		if !FS.exist(data[key].str):
			data.erase(key)
			continue
		if data[key].keys().has("res"):
			data[key].res = load(data[key].str)
	if data != dup:
		FS.write(save_file,JSON.stringify(data))
	is_data_loaded = true
	data_loaded.emit()

func _ready() -> void:
	load_data_file()
	get_tree().set_auto_accept_quit(false)

func _notification(what : int) -> void:
	if what == NOTIFICATION_CRASH || what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()

func search(path : String, content : String, ignore_godot_folder : bool = true) -> Variant:
	var files : Array = FS.read_dir(path)
	for file in files:
		if ((".godot" in file && ignore_godot_folder) || ModManager.mod_folder in file) && FS.is_dir(file):
			continue
		if file.get_file() == content:
			return file
		if FS.is_dir(file):
			var result : Variant = search(file + "/", content, ignore_godot_folder)
			if result:
				return result
	return null

func request_resource(filename : String, only_path : bool = false, ignore_godot_folder : bool = true) -> Variant:
	if !is_data_loaded:
		await data_loaded
	if data.keys().has(filename) && FS.exist(data[filename].str):
		return data[filename].res if data[filename].keys().has("res") && !only_path else data[filename].str
	var result : Variant = search(FS.root_dir(),filename, ignore_godot_folder)
	if result:
		if only_path:
			data[filename] = {"str":result}
		else:
			data[filename] = {"str":result,"res":load(result)}
			result = data[filename].res
		FS.write(save_file,JSON.stringify(data))
	else:
		push_error("\""+filename+"\" not found")
	return result
