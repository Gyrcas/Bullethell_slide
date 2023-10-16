@tool
extends TextEdit

func _ready() -> void:
	connect("text_changed",_on_text_changed)

func _on_text_changed() -> void:
	get_node("../../").content = text

func _process(_delta) -> void:
	if not get_node("../../") is DialogueBox || text == get_node("../../").content:
		return
	text = get_node("../../").content
