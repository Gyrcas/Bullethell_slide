@tool
extends DialogueNode
class_name DialoguePlayer
## Let you play dialogue

@export var confirm_action : String = "ui_accept" : set = set_confirm_action

func set_confirm_action(value : String) -> void:
	confirm_action = value
	update_configuration_warnings()

# Timer used to count time between letter in the typewriter
var write_timer : Timer = Timer.new()

func _ready() -> void:
	_class.append("DialoguePlayer")
	if Engine.is_editor_hint():
		return
	add_child(write_timer)
	write_timer.connect("timeout",write_timer_timeout)

# Allows to skip typewriter text and to continue dialogue if the box is a
# DialogueBoxMSG
func _input(event : InputEvent) -> void:
	if event.is_action_pressed(confirm_action):
		if current_dialogue_box:
			if UT.has_class_ancestor(current_dialogue_box,"DialogueBox"):
				if is_writing:
					is_writing = false
					if text_node:
						text_node.text = current_dialogue_box.text
						return
				if UT._is_class(current_dialogue_box,"DialogueBoxMSG"):
					if current_dialogue_box.get_child_count() > 0:
						play_dialogue_box(current_dialogue_box.get_child(0))

# Add one letter at timeout
func write_timer_timeout() -> void:
	if !is_writing:
		return
	var string : String = current_dialogue_box.text.erase(0,text_node.text.length())
	if string.is_empty():
		is_writing = false
		return
	text_node.text += string[0]
	write_timer.start(typewriter_speed)

## Where the DialogueBox text will be displayed
@export var text_node : Control : set = set_text_node
## Where the buttons for DialogueBoxChoice will be created
@export var button_container : Control : set = set_button_container
@export_group("Typewriter")
## If on, add a typewritter effect when the text appear. Can be skipped
@export var use_typewriter : bool = true
## Time in second between each letter
@export_range(0.001,1) var typewriter_speed : float = 0.01

# Bool used to know if the typewriter is currently typing
var is_writing : bool = false

var current_dialogue_box : DialogueBox = null

func set_button_container(value : Control) -> void:
	button_container = value
	update_configuration_warnings()

# Check if given Control has a text property before accepting new value
func set_text_node(value : Control) -> void:
	if !value:
		return
	if value.get("text") || value.get("text") == "":
		text_node = value
		update_configuration_warnings()

# If using typewriter, start typewriter effect, else just assign text to text node
func write() -> void:
	if use_typewriter:
		is_writing = true
		write_timer.start()
		return
	text_node.text = current_dialogue_box.text

# Behaviors for all the different kinds of DialogueBox
func play_dialogue_box(dialogue_box : DialogueBox) -> void:
	if !dialogue_box:
		push_error("dialogue_box can't be null")
		return
	if !UT.has_class_ancestor(dialogue_box,"DialogueBox"):
		push_error("dialogue_box is not a DialogueBox")
		return
	current_dialogue_box = dialogue_box
	write_timer.stop()
	if !text_node:
		push_error("No text node set")
		return
	if !button_container:
		push_error("No button container set")
		return
	text_node.text = ""
	UT.remove_children(button_container)
	match UT._get_class(current_dialogue_box):
		"DialogueBoxMSG":
			write()
		"DialogueBoxChoice":
			write()
			write_timer.start(typewriter_speed)
			for child in dialogue_box.get_children():
				if !UT._is_class(child,"DialogueBoxChoiceOption"):
					push_error("child \"" + child.name + "\" is not a DialogueBoxChoiceOption")
					continue
				var new_button : Button = Button.new()
				new_button.text = child.text
				new_button.connect("pressed",dialogue_choice_pressed.bind(child))
				button_container.add_child(new_button)
		"DialogueBoxChoiceOption":
			if dialogue_box.get_child_count() < 1:
				return
			play_dialogue_box(dialogue_box.get_child(0))
		"DialogueBoxCondition":
			var node : Node = Node.new()
			node.set_script(load(dialogue_box.script_file))
			if node.call(dialogue_box.method_name):
				play_dialogue_box(dialogue_box.get_child(0))
				return
			play_dialogue_box(dialogue_box.get_child(1))
		"DialogueBoxMoveTo":
			play_dialogue_box(dialogue_box.get_box_by_id(dialogue_box.move_to))
		"DialogueBoxScript":
			var node : Node = Node.new()
			node.set_script(load(dialogue_box.script_file))
			node.call(dialogue_box.method_name)
			if dialogue_box.get_child_count() < 1:
				return
			play_dialogue_box(dialogue_box.get_child(0))

# Play the choice option associated with the button
func dialogue_choice_pressed(choice_option : DialogueBoxChoiceOption) -> void:
	play_dialogue_box(choice_option)

func play(dialogue_tree : DialogueTree) -> void:
	if UT._get_class(dialogue_tree) != "DialogueTree":
		push_error("dialogue_tree is not a DialogueTree")
		return
	if dialogue_tree.get_child_count() > 0:
		var child : Node = dialogue_tree.get_child(0)
		if UT.has_class_ancestor(child,"DialogueBox"):
			play_dialogue_box(child)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if !text_node:
		warnings.append("dialogue node not set")
	if !button_container:
		warnings.append("button container not set")
	if !InputMap.get_actions().has(confirm_action):
		warnings.append("confirm action name \"" + confirm_action + "\" doesn't exist")
	return warnings
