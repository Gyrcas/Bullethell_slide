extends Node

var data : Dictionary = {
	"intro" : false
}

func save_data(path : String) -> void:
	FS.write(path,JSON.stringify(data))

func load_data(path : String) -> void:
	data = JSON.parse_string(FS.read(path))
