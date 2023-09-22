@tool
extends DialogueBox
class_name DialogueBoxMoveTo
## Used to move to a different DialogueBox

## ID of the DialogueBox to move to
@export var move_to : int = 0 : set = set_move_to

func _ready() -> void:
	super()
	_class.append("DialogueBoxMoveTo")

func set_move_to(value : int) -> void:
	move_to = value
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	warnings += default_warnings()
	if get_child_count() > 1:
		warnings.append("Children count above 1")
	var dialogue_tree : DialogueTree = get_dialogue_tree()
	if valide_dialogue_tree(dialogue_tree):
		if !dialogue_tree.used_ids.has(move_to):
			warnings.append("ID " + str(move_to) + " doesn't exist")
	return warnings
