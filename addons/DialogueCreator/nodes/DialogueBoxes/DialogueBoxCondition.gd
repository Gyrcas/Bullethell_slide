@tool
extends DialogueBoxScript
class_name DialogueBoxCondition
## Used to have a function that return a bool, if true, take first child, else take 
## second child

func _ready() -> void:
	super()
	_class.append("DialogueBoxCondition")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	warnings += default_warnings()
	warnings += script_warnings()
	if get_child_count() != 2:
		warnings.append("This node must have two DialogueBox children")
	if script_file && script_file != "":
		if method_name && method_name != "":
			var node : Node = Node.new()
			node.set_script(load(script_file))
			if node.has_method(method_name):
				if !UT.is_type(node.call(method_name),"bool"):
					warnings.append("Method \"" + method_name + "\" doesn't return a bool")
	return warnings
