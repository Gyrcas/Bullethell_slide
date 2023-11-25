extends Node

func _ready() -> void:
	var content : String = "extends Node\n"
	content = read("res://", content)
	FS.write("res://singletons/FileLoader.gd",content)
	

func read(dir : String, text : String) -> String:
	var files : Array = FS.read_dir(dir)
	for file in files:
		if FS.is_file(file):
			var new_var : String = "const "+file.get_file().replace(".","_").replace(" ","_").replace("-","_")
			if !text.contains(new_var):
				text += new_var+" : String = \""+file+"\"\n"
		elif FS.is_dir(file) && not ".godot" in file:
			text = read(file,text)
	return text
