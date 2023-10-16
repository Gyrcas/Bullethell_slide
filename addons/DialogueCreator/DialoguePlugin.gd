@tool
extends EditorPlugin

const path : String = "res://addons/DialogueCreator/"
var dock : Control = preload(path + "creator_interface.tscn").instantiate()

func _enter_tree() -> void:
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)


func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()
