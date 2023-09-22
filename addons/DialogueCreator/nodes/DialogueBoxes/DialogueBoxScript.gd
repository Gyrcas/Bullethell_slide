@tool
extends DialogueBox
class_name DialogueBoxScript
## Used to execute script while in dialogue

func _ready() -> void:
	super()
	_class.append("DialogueBoxScript")

## The gd file that will be used
@export_file("*.gd") var script_file : String : set = set_script_file
## The name of the method to call
@export var method_name : String = "dialogue" : set = set_method_name

func set_method_name(value : String) -> void:
	method_name = value
	update_configuration_warnings()

# Check if file exist and if is a gd file before accepting new value
func set_script_file(value : String) -> void:
	if !FS.is_file(value):
		return
	if value.get_extension() != "gd":
		return
	script_file = value
	update_configuration_warnings()

# Default warning for the two script nodes
func script_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if script_file && script_file != "":
		if method_name && method_name != "":
			var node : Node = Node.new()
			node.set_script(load(script_file))
			if !node.has_method(method_name):
				warnings.append("Script file \"" + script_file + "\" doesn't have \"" + method_name + "\" method")
		else:
			warnings.append("Method name not set")
	else:
		warnings.append("Script file not set")
	return warnings

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	warnings += default_warnings()
	if get_child_count() > 1:
		warnings.append("Children count above 1")
	warnings += script_warnings()
	return warnings
