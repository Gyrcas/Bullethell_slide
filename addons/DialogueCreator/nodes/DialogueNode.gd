@tool
extends Node
class_name DialogueNode
## This class is abstract, don't use it

# Contains all inherited custom classes
var _class : PackedStringArray = ["DialogueNode"]

func _get_configuration_warnings() -> PackedStringArray:
	return ["This class is meant as an abstract class, it is useless as a node"]
