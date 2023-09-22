@tool
extends DialogueNode
class_name DialogueTree
## Used to manage things related to the dialogue. Serve as a start before adding
## DialogueBox

# Contains all ids used by the DialogueBox
var used_ids : Array[int] = []

# Find and return the DialogueBox with the given id, or null
func get_box_by_id(id : int, parent_node : DialogueNode = self) -> DialogueBox:
	for child in parent_node.get_children():
		if UT.has_class_ancestor(child,"DialogueBox"):
			if child.id == id:
				return child
			if child.get_child_count() > 0:
				var result : DialogueBox = get_box_by_id(id,child)
				if result:
					return result
	return null

# Load IDs of all children
func setup_ids(parent_node : Node) -> void:
	for child in parent_node.get_children():
		if child.has_method("id_setup"):
			child.id_setup()
		if child.get_child_count() > 0:
			setup_ids(child)


func _ready() -> void:
	_class.append("DialogueTree")
	if Engine.is_editor_hint():
		setup_ids(self)
	else:
		used_ids.clear()
	

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if get_child_count() > 1:
		warnings.append("Children count above 1")
	if get_child_count() == 1 && !UT.get_class_ancestors(get_child(0)).has("DialogueBox"):
		warnings.append("Child is not a DialogueBox")
	return warnings
