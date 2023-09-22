@tool
extends EditorPlugin


func _enter_tree() -> void:
	var path : String = "res://addons/DialogueCreator/"
	add_custom_type("DialogueNode","Node",load(path + "nodes/DialogueNode.gd"),load(path + "icons/icon.svg"))
	add_custom_type("DialoguePlayer","DialogueNode",load(path + "nodes/DialoguePlayer.gd"),load(path + "icons/icon.svg"))
	add_custom_type("DialogueTree","DialogueNode",load(path + "nodes/DialogueTree.gd"),load(path + "icons/icon.svg"))
	add_custom_type("DialogueBox","DialogueNode",load(path + "nodes/DialogueBox.gd"),load(path + "icons/icon.svg"))
	add_custom_type("DialogueBoxChoice","DialogueBox",load(path + "nodes/DialogueBoxes/DialogueBoxChoice.gd"),load(path + "icons/icon.svg"))
	add_custom_type("DialogueBoxChoiceOption","DialogueBox",load(path + "nodes/DialogueBoxes/DialogueBoxChoiceOption.gd"),load(path + "icons/icon.svg"))
	add_custom_type("DialogueBoxScript","DialogueBox",load(path + "nodes/DialogueBoxes/DialogueBoxScript.gd"),load(path + "icons/icon.svg"))
	add_custom_type("DialogueBoxCondition","DialogueBoxScript",load(path + "nodes/DialogueBoxes/DialogueBoxCondition.gd"),load(path + "icons/icon.svg"))
	add_custom_type("DialogueBoxMoveTo","DialogueBox",load(path + "nodes/DialogueBoxes/DialogueBoxMoveTo.gd"),load(path + "icons/icon.svg"))
	add_custom_type("DialogueBoxMSG","DialogueBox",load(path + "nodes/DialogueBoxes/DialogueBoxMSG.gd"),load(path + "icons/icon.svg"))


func _exit_tree() -> void:
	remove_custom_type("DialogueNode")
	remove_custom_type("DialoguePlayer")
	remove_custom_type("DialogueTree")
	remove_custom_type("DialogueBox")
	remove_custom_type("DialogueBoxChoice")
	remove_custom_type("DialogueBoxChoiceOption")
	remove_custom_type("DialogueBoxScript")
	remove_custom_type("DialogueBoxCondition")
	remove_custom_type("DialogueBoxMoveTo")
	remove_custom_type("DialogueBoxMSG")
