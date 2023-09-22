@tool
extends Node
#class_name FS
## Used to make managing files a little easier



# Write to a file the given content, overwrite everything
# parameters:
# 	file_path -> path of the file
# 	content -> what will be written file
func write(file_path : String, content : String) -> void:
	if !is_dir(file_path.get_base_dir()):
		push_error(file_path + " is not a file")
		return
	var file : FileAccess = FileAccess.open(file_path,FileAccess.WRITE)
	file.store_string(content)

func write_absolute(file_path : String, content : String) -> void:
	create_dir_absolute(file_path.get_base_dir())
	write(file_path,content)

func create_dir_absolute(dir_path : String) -> void:
	var dir_to_create : Array[String] = []
	var current_dir : String = dir_path
	while !is_dir(current_dir):
		dir_to_create.append(current_dir)
		current_dir = current_dir.get_base_dir()
	while !dir_to_create.is_empty():
		create_dir(dir_to_create.pop_back())
		

func create_dir(dir_path : String) -> void:
	var dir_parent : String = dir_path.get_base_dir()
	if !is_dir(dir_parent):
		push_error(dir_parent + " doesn't exist")
		return
	if dir_path.get_extension() != "":
		push_error("dir can't have extension")
		return
	var dir : DirAccess = DirAccess.open(dir_parent)
	dir.make_dir(dir_path.get_file())

# Get all files and directories inside a directory
# parameters:
# 	dir_path -> path of the dir
# return -> array containing the name of all the files and directories inside the given path
func read_dir(dir_path : String) -> Array:
	if !is_dir(dir_path):
		push_error(dir_path + " is not a dir")
		return []
	var dir : DirAccess = DirAccess.open(dir_path)
	if !dir:
		push_error("Dir unexpected null")
		return []
	var files : Array = dir.get_directories() + dir.get_files()
	for i in files.size():
		if dir_path.right(1) != "/":
			files[i] = dir_path + "/" + files[i]
		else:
			files[i] = dir_path + files[i]
	return files

# get the text content of a file
# parameters:
# 	file_path -> path of the file
# return -> the text content of the file
func read(file_path : String) -> String:
	if !is_file(file_path):
		push_error(file_path + " is not a file")
		return ""
	var file : FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var content : String = file.get_as_text()
	return content

# Check if a file exist
# parameters:
# 	file_path -> path of the file
# return -> true if file exist
func is_file(file_path : String) -> bool:
	return FileAccess.file_exists(file_path)

# Check if dir exist
# parameters:
# 	dir_path -> path of the dir
# return -> true if dir exist
func is_dir(dir_path : String) -> bool:
	if dir_path == "":
		return false
	return DirAccess.dir_exists_absolute(dir_path)

func exist(file_path) -> bool:
	return is_file(file_path) || is_dir(file_path)

func delete(file_path : String) -> void:
	if !exist(file_path):
		push_error(file_path + " doesn't exist")
		return
	var dir : DirAccess = DirAccess.open(file_path.get_base_dir())
	dir.remove(file_path)

func delete_all(dir_path : String) -> void:
	if !is_dir(dir_path):
		push_error(dir_path + " doesn't exist")
		return
	var files : Array = read_dir(dir_path)
	for file in files:
		delete(file)

