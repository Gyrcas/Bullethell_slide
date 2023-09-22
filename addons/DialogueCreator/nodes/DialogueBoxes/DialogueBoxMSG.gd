@tool
extends DialogueBox
class_name DialogueBoxMSG
## Used to display a DialogueBox with only text

func _ready() -> void:
	super()
	_class.append("DialogueBoxMSG")

## Text that will be displayed in the dialogue node
@export_multiline var text : String = ""

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	warnings += default_warnings()
	if get_child_count() > 1:
		warnings.append("Children count above 1")
	return warnings

