@tool
extends Node
class_name DialoguePlayer

@export var button_container : Node

@export var text_node : Node : set = set_text_node

enum types {msg,script,choice,condition,move_to,placeholder,choice_option}

func set_text_node(value : Node) -> void:
	if !value.get("text"):
		push_error("Node doesn't have text variable")
		return
	text_node = value

func play(dialogue : Dictionary) -> void:
	match dialogue.type:
		"":
			pass

func play_from_file(path : String) -> void:
	if !FileAccess.file_exists(path):
		push_error("File \"" + path + "\" doesn't exist")
		return
	var file : FileAccess = FileAccess.open(path,FileAccess.READ)
	var dialogue : Dictionary = JSON.parse_string(file.get_as_text())
	play(dialogue)
