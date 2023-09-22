@tool
extends DialogueNode
class_name DialogueBox
## This class is abstract, don't use it

@export var id : int = -1 : set = set_id

func get_box_by_id(_id : int, parent_node : DialogueNode = get_dialogue_tree()) -> DialogueBox:
	for child in parent_node.get_children():
		if UT.has_class_ancestor(child,"DialogueBox"):
			if child.id == _id:
				return child
			if child.get_child_count() > 0:
				var result : DialogueBox = get_box_by_id(id,child)
				if result:
					return result
	return null

func set_id(value : int) -> void:
	var dialogue_tree : DialogueTree = get_dialogue_tree()
	if !valide_dialogue_tree(dialogue_tree):
		id = -1
		return
	if value < -1:
		return
	if dialogue_tree.used_ids.has(id):
		dialogue_tree.used_ids.erase(id)
	if dialogue_tree.used_ids.has(value):
		get_first_available_id()
		return
	id = value
	dialogue_tree.used_ids.append(id)

func get_dialogue_tree() -> DialogueTree:
	var ancestor : Node = get_parent()
	while ancestor && !UT._is_class(ancestor,"DialogueTree"):
		ancestor = ancestor.get_parent()
	if !ancestor:
		return null
	return ancestor

func get_first_available_id() -> void:
	var dialogue_tree : DialogueTree = get_dialogue_tree()
	if !valide_dialogue_tree(dialogue_tree):
		return
	var new_id : int = 0
	while dialogue_tree.used_ids.has(new_id):
		new_id += 1
	id = new_id
	dialogue_tree.used_ids.append(id)

func valide_dialogue_tree(dialogue_tree : DialogueTree) -> bool:
	return dialogue_tree && UT._is_class(dialogue_tree,"DialogueTree")

func id_setup() -> void:
	if id == -1:
		get_first_available_id()

func _ready() -> void:
	_class.append("DialogueBox")
	id_setup()

func default_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	var dialogue_tree : DialogueTree = get_dialogue_tree()
	if !valide_dialogue_tree(dialogue_tree):
		warnings.append("Ancestor DialogueTree not found")
	for child in get_children():
		if !UT.has_class_ancestor(child,"DialogueBox"):
			print(UT.get_class_ancestors(child))
			warnings.append("Child \"" + child.name + "\" is not a DialogueBox")
	if id < 0:
		warnings.append("ID must be above or equal to zero")
	return warnings
