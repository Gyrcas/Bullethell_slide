@tool
extends TextEdit

const max_retry : int = 5

var default_size : Vector2 = size
var zoom : float = 1
var focused : bool = false

func _ready() -> void:
	connect("text_changed",_on_text_changed)

func _on_text_changed() -> void:
	get_node("../../").content = text

func set_content(retry : int = 0) -> void:
	retry += 1
	if retry < max_retry:
		var parent : Node = get_node("../../")
		if not parent is DialogueBox:
			set_content.call_deferred(retry)
			return
		if text != parent.content || parent.content == "" || parent.zoom == 1 || parent.zoom != zoom:
			if get_tree():
				await get_tree().create_timer(0.1).timeout
			text = parent.content
			zoom = parent.zoom
			focused = false
			set_content.call_deferred(retry)

func _input(event : InputEvent):
	if focused && event is InputEventKey && event.is_pressed():
		match event.as_text():
			"Ctrl+Equal":
				zoom += 0.05
				size = default_size * zoom
			"Ctrl+Minus":
				zoom = zoom - 0.05 if zoom > 1 else 1
				size = default_size * zoom
		if get_node("../../") is DialogueBox:
			get_node("../../").zoom = zoom

func _on_focus_entered() -> void:
	size = default_size * zoom
	z_index = 100
	focused = true


func _on_focus_exited() -> void:
	size = default_size
	z_index = 0
	focused = false
