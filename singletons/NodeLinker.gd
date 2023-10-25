extends Node

const bullet_scene : String = "res://entities/bullet.tscn"

const death_particles : String = "res://resources/death_particles.tscn"

const auto_save_file : String = "res://data/auto_save.json"

var player : Player = null

const auto_target_collision_level : int = 3

var translations : String = OS.get_executable_path().get_base_dir() + "/data/translation"

const save_file : String = "res://resources/nodelinker_data.json"

var data : Dictionary = {}

func _ready() -> void:
	data = JSON.parse_string(FS.read(save_file))
	for file in data.values():
		if !FS.exist(file.str):
			file = null
			continue
		if file.keys().has("res"):
			file.res = load(file.str)
			

func search(path : String, content : String, ignore_godot_folder : bool = true) -> Variant:
	var files : Array = FS.read_dir(path)
	for file in files:
		if file == ".godot" && ignore_godot_folder:
			continue
		if file.get_file() == content:
			return file
		if FS.is_dir(file):
			var result : Variant = search(file + "/", content, ignore_godot_folder)
			if result:
				return result
	return null

func request_resource(filename : String, only_path : bool = false, ignore_godot_folder : bool = true) -> Variant:
	if data.keys().has(filename) && FS.exist(data[filename].str):
		return data[filename].res if data[filename].keys().has("res") && !only_path else data[filename].str
	var result : Variant = search("res://",filename, ignore_godot_folder)
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
