extends Node

var save_file : String = "res://resources/nodelinker_data.json"

const mod_folder : String = "mods/"

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

var active_mods : Array = []

func get_mods_list() -> PackedStringArray:
	var mods : Array = active_mods.duplicate()
	for mod in FS.read_dir(FS.root_dir() + mod_folder,false):
		if !mods.has(mod):
			mods.append(mod)
	return mods

func apply_mods(old_mods : Array = []) -> void:
	FS.write(
		await request_resource("active_mods.json",true),
		JSON.stringify(active_mods)
	)
	load_mods(old_mods)

func fetch_mods() -> void:
	active_mods = JSON.parse_string(
		FS.read(await request_resource("active_mods.json",true))
	)

func load_mods(old_mods : Array = []) -> void:
	for mod in old_mods:
		remove_mod(mod)
	for mod in active_mods:
		load_mod(mod)

func load_mod(mod_name : String, path : String = get_mod_path(mod_name)) -> void:
	for file in FS.read_dir(path):
		if FS.is_dir(file):
			load_mod(mod_name,file)
		if FS.is_file(file) && file.get_extension() == "tscn":
			var real_file : String = FS.root_dir() + file.get_base_dir().replace(get_mod_path(mod_name),"")
			if !FS.is_file(real_file):
				continue
			var pack : PackedScene = load(real_file)
			var base : Node = pack.instantiate()
			var addon : Node = load(file).instantiate()
			base.add_child(addon)
			addon.add_to_group("mod_"+mod_name,true)
			addon.owner = base
			pack.pack(base)
			ResourceSaver.save(pack,real_file)
			base.queue_free()

func remove_mod(mod_name : String, path : String = get_mod_path(mod_name)) -> void:
	for file in FS.read_dir(path):
		if FS.is_dir(file):
			remove_mod(mod_name,file)
		if FS.is_file(file) && file.get_extension() == "tscn":
			var real_file : String = FS.root_dir() + file.get_base_dir().replace(get_mod_path(mod_name),"")
			if !FS.is_file(real_file):
				continue
			var pack : PackedScene = load(real_file)
			var node : Node = pack.instantiate()
			for child in node.get_children():
				if child.is_in_group("mod_"+mod_name):
					child.free()
			pack.pack(node)
			ResourceSaver.save(pack,real_file)
			node.queue_free()

func get_mod_path(mod : String) -> String:
	return FS.root_dir() + mod_folder + mod + "/"

func _ready() -> void:
	fetch_mods()
	load_data_file()
	get_tree().set_auto_accept_quit(false)

func _notification(what : int) -> void:
	if what == NOTIFICATION_CRASH || what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()

func search(path : String, content : String, ignore_godot_folder : bool = true) -> Variant:
	var files : Array = FS.read_dir(path)
	for file in files:
		if ((".godot" in file && ignore_godot_folder) || mod_folder in file) && FS.is_dir(file):
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
	var result : Variant = search(OS.get_executable_path().get_base_dir() + "/",filename, ignore_godot_folder)
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
