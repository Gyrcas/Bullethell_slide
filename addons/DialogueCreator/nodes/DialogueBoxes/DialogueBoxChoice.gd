@tool
extends DialogueBox
class_name DialogueBoxChoice
## Used to offer a choice in the dialogue

## Text that will be displayed in the dialogue node
@export_multiline var text : String = ""

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	warnings += default_warnings()
	if get_child_count() < 1:
		warnings.append("Child count must be above 0")
	for child in get_children():
		if !UT._is_class(child,"DialogueBoxChoiceOption"):
			warnings.append("Child \"" + child.name + "\" is not a DialogueBoxChoiceOption")
	return warnings

func _ready() -> void:
	super()
	_class.append("DialogueBoxChoice")
