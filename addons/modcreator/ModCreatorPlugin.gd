@tool
extends EditorPlugin

const path : String = "res://addons/ModCreator/"

func _enter_tree() -> void:
	add_autoload_singleton("ModManager",path+"ModManager.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("ModManager")
