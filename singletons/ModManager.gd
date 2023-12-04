extends Node

const mod_folder : String = "mods/"

var active_mods : Array = []

func get_mods_list() -> PackedStringArray:
	var mods : Array = active_mods.duplicate()
	for mod in FS.read_dir(FS.root_dir() + mod_folder,false):
		if !mods.has(mod):
			mods.append(mod)
	return mods

func apply_mods(old_mods : Array = []) -> void:
	FS.write(
		await NodeLinker.request_resource("active_mods.json",true),
		JSON.stringify(active_mods)
	)
	load_mods(old_mods)

func fetch_mods() -> void:
	active_mods = JSON.parse_string(
		FS.read(await NodeLinker.request_resource("active_mods.json",true))
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
