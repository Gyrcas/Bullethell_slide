@tool
extends Node
class_name DialoguePlayer

@export var action_next : String = "ui_accept" : set = set_action_next

func set_action_next(value : String) -> void:
	action_next = value
	update_configuration_warnings()

@export var button_container : Node

@export var text_node : Node

enum types {msg,script,choice,condition,move_to,placeholder,choice_option}

func get_dialogue_by_id(id : int, dialogue : Dictionary) -> Variant:
	if dialogue.id == id:
		return dialogue
	for child in dialogue.children:
		var result : Variant = get_dialogue_by_id(id, child)
		if result:
			return result
	return null

signal confirm

func _input(event : InputEvent) -> void:
	if event.is_action_pressed(action_next):
		confirm.emit()

func play(dialogue : Dictionary, current_dialogue : Dictionary = dialogue) -> void:
	if current_dialogue == {}:
		return
	if button_container.get_child_count() > 0:
		for child in button_container.get_children():
			child.queue_free()
	match int(current_dialogue.type):
		types.msg:
			text_node.text = current_dialogue.content
			await confirm
			play(dialogue,current_dialogue.children[0] if current_dialogue.children.size() > 0 else {})
		types.script:
			var split : PackedStringArray = current_dialogue.content.split("?")
			var node : Node = Node.new()
			node.set_script(load(split[0]))
			node.call(split[1])
			node.queue_free()
			if current_dialogue.children.size() > 0:
				play(dialogue,current_dialogue.children[0])
		types.choice:
			text_node.text = current_dialogue.content
			for child in current_dialogue.children:
				var button : Button = Button.new()
				button.text = child.content
				button.connect("pressed",play.bind(dialogue,child.children[0] if child.children.size() > 0 else {}))
				button_container.add_child(button)
		types.condition:
			var split : PackedStringArray = current_dialogue.content.split("?")
			var node : Node = Node.new()
			node.set_script(load(split[0]))
			var result : bool = node.call(split[1])
			node.queue_free()
			play(dialogue,current_dialogue.children[0] if result else current_dialogue.children[1])
		types.move_to:
			print(get_dialogue_by_id(int(current_dialogue.content),dialogue))
			play(dialogue,get_dialogue_by_id(int(current_dialogue.content),dialogue))
			

func play_from_file(path : String) -> void:
	if !FileAccess.file_exists(path):
		push_error("File \"" + path + "\" doesn't exist")
		return
	var file : FileAccess = FileAccess.open(path,FileAccess.READ)
	var dialogue : Dictionary = JSON.parse_string(file.get_as_text())
	play(dialogue)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if !InputMap.get_actions().has(action_next):
		warnings.append("Action \"" + action_next + "\" doesn't exist")
	return warnings
