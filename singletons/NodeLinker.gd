extends Node

var save_file : String = "res://resources/nodelinker_data.json"

const mod_folder : String = "mods/"

const backup_folder : String = "backup/"

var data : Dictionary = {}

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
		print(data)
		FS.write(save_file,JSON.stringify(data))

var active_mods : Array = []

func get_mods_list() -> PackedStringArray:
	var list : Array = FS.read_dir(FS.root_dir() + mod_folder,false)
	list.erase(backup_folder.split("/")[0])
	return list

func apply_mods() -> void:
	FS.write(
		request_resource("active_mods.json",true),
		JSON.stringify(active_mods)
	)
	load_mods()

func fetch_mods() -> void:
	active_mods = JSON.parse_string(
		FS.read(request_resource("active_mods.json",true))
	)

func load_mods() -> void:
	load_backup()
	
	for mod in active_mods:
		load_mod(mod)
	
	load_data_file()

func load_mod(mod_name : String, path : String = FS.root_dir() + mod_folder + mod_name + "/") -> void:
	var mod_path : String = FS.root_dir() + mod_folder + mod_name + "/"
	for file in FS.read_dir(path):
		if FS.is_dir(file):
			load_mod(mod_name,file)
		if FS.is_file(file) && file.get_extension() == "tscn":
			var real_file : String = FS.root_dir() + file.get_base_dir().replace(mod_path,"")
			if !FS.is_file(real_file):
				continue
			var pack : PackedScene = load(real_file)
			var base : Node = pack.instantiate()
			var addon : Node = load(file).instantiate()
			base.add_child(addon)
			addon.owner = base
			pack.pack(base)
			ResourceSaver.save(pack,real_file)

func do_backup(path : String = FS.root_dir()) -> void:
	for file in FS.read_dir(path):
		if (".godot" in file || backup_folder in file || mod_folder in file) && FS.is_dir(file): continue
		if file.get_extension() == "tscn":
			var local_path : String = file.replace(FS.root_dir(),"")
			FS.write_absolute(
				FS.root_dir() + mod_folder + backup_folder + local_path,
				FS.read(file)
			)
		if FS.is_dir(file):
			do_backup(file + "/")

func load_backup(path : String = FS.root_dir() + mod_folder + backup_folder) -> void:
	for file in FS.read_dir(path):
		var backup : String = file.replace(FS.root_dir() + mod_folder + backup_folder,"")
		var real_file : String = FS.root_dir() + backup
		if FS.is_file(real_file):
			FS.write(real_file,FS.read(file))
		if FS.is_dir(file):
			load_backup(file + "/")

func _init() -> void:
	do_backup()
	fetch_mods()
	load_mods()

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)

func _notification(what : int) -> void:
	if what == NOTIFICATION_CRASH || what == NOTIFICATION_WM_CLOSE_REQUEST:
		load_backup()
		get_tree().quit()

func search(path : String, content : String, ignore_godot_folder : bool = true) -> Variant:
	var files : Array = FS.read_dir(path)
	for file in files:
		if ((".godot" in file && ignore_godot_folder) || mod_folder in file || backup_folder in file) && FS.is_dir(file):
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
