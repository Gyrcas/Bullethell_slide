@tool
extends DialogueBox
class_name DialogueBoxChoiceOption
## Used to add option to DialogueBoxChoice node

## Text that will be displaon the choice button
@export_multiline var text : String = ""

func _ready() -> void:
	super()
	_class.append("DialogueBoxChoiceOption")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	warnings += default_warnings()
	if get_child_count() > 1:
		warnings.append("Children count above 1")
	if !UT._is_class(get_parent(),"DialogueBoxChoice"):
		warnings.append("Parent is not a DialogueBoxChoice")
	return warnings
