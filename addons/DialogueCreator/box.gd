@tool
extends Control
class_name DialogueBox

@onready var header : Panel = $header
@onready var header_theme : StyleBoxFlat = $header.get("theme_override_styles/panel")
@onready var type_select : OptionButton = $header/center/hbox/type
@onready var body : CenterContainer = $body
@onready var id_lbl : Label = $header/center/hbox/id

#Types of boxes and their attributs
enum types {msg,script,choice,condition,move_to,placeholder,choice_option}
@onready var type_params : Dictionary = {
	types.msg : {
		"color":Color("5198ff"),
		"body":"res://addons/DialogueCreator/msg.tscn"
	},
	types.script : {
		"color":Color("fcb100"),
		"body":"res://addons/DialogueCreator/script.tscn"
	},
	types.choice : {
		"color":Color("b723c2"),
		"body":"res://addons/DialogueCreator/choice.tscn"
	},
	types.choice_option : {
		"color":Color("7b1782"),
		"body":"res://addons/DialogueCreator/msg.tscn"
	},
	types.condition : {
		"color":Color("e319c1"),
		"body":"res://addons/DialogueCreator/script.tscn"
	},
	types.move_to : {
		"color":Color("0ad135"),
		"body":"res://addons/DialogueCreator/move_to.tscn"
	},
	types.placeholder : {
		"color":Color("7a7a7a"),
		"body":"res://addons/DialogueCreator/placeholder.tscn"
	}
}

var interface : DialogueCreatorInterface

var id : int = -1 : set = set_id

func set_id(value : int) -> void:
	id = value
	if id_lbl:
		id_lbl.text = str(id)
	else:
		set_id.call_deferred(id)

#Used by the dialogueplayer to display text or execute file
var content : String = ""
	

# "Parent" of the box, not the node's parent
var parent : DialogueBox

# "Children" of the box, not the node's children
var children : Array[DialogueBox] = [] : set = set_children

func set_children(value : Array[DialogueBox]) -> void:
	children = value
	for child in children:
		child.parent = self

func _notification(what : int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED && interface:
		interface.queue_redraw()

func _ready() -> void:
	
	#Create list of types
	set_notify_transform(true)
	type_select.clear()
	for type in types.keys():
		type_select.add_item(type.replace("_"," "),types[type])
		if [types.placeholder,types.choice_option].has(types[type]):
			type_select.set_item_disabled(types[type],true)
	#If parent, new nodes become place holders unless there parent is a choice
	if parent:
		if parent.type_select.selected == types.choice:
			_on_type_item_selected(types.choice_option)
		else:
			_on_type_item_selected(types.placeholder)
	else:
		#If no parent, means it's first so msg
		_on_type_item_selected(types.msg)
		

func add_child_box(type : int = types.placeholder,offset : Vector2 = Vector2.ZERO) -> void:
	if not get_parent() is Control:
		return
	var placeholder : DialogueBox  = load("res://addons/DialogueCreator/box.tscn").instantiate()
	children.append(placeholder)
	placeholder.parent = self
	get_parent().add_child(placeholder)
	placeholder.global_position = global_position + Vector2(275,0) * interface.zoom + offset
	placeholder._on_type_item_selected(type)

# Remove all children except one and add a placeholder if no children
func default_children_method() -> void:
	#Remove all children except one
	while children.size() > 1:
		children[0].queue_free()
		children.pop_front()
	#Create placeholder
	if children.size() == 0:
		add_child_box()
	elif children[0].type_select.selected == types.choice_option:
		#Transform the choice option into msg if choice option
		children[0]._on_type_item_selected(types.msg)

var zoom : float = 1

func _on_type_item_selected(idx : int) -> void:
	if !types.values().has(idx):
		push_error("Non existing type")
		return
	#Assign box color
	header_theme.bg_color = type_params[idx].color
	header.set("theme_override_styles/panel",header_theme)
	
	type_select.disabled = false
	
	#Remove old body and load the new corresponding body
	if body.get_child_count() > 0:
		body.get_child(0).queue_free()
	body.add_child(load(type_params[idx].body).instantiate())
	
	#Action for each boxes
	match idx:
		types.msg:
			default_children_method()
		types.script:
			default_children_method()
			content = "?"
		types.choice:
			chain_delete(self,false)
		types.choice_option:
			default_children_method()
			type_select.disabled = true
		types.condition:
			chain_delete(self,false)
			add_child_box()
			add_child_box(types.placeholder,Vector2(0,300))
			content = "?"
		types.move_to:
			chain_delete(self,false)
		types.placeholder:
			chain_delete(self,false)
			type_select.disabled = true
	type_select.selected = idx

#Delete every "children" of boxes because they are not the real children of box
func chain_delete(parent : DialogueBox, delete_self : bool = true) -> void:
	for child in parent.children:
		child.chain_delete(child)
	parent.children = []
	if delete_self:
		queue_free()

# Delete all "children" then turn self into placeholder
func _on_delete_pressed() -> void:
	if types.choice_option != type_select.selected:
		chain_delete(self,false)
		_on_type_item_selected(types.placeholder)
	else:
		chain_delete(self)


#Box movement with mouse
var mouse_offset : Vector2 = Vector2.ZERO
var follow_mouse : bool = false

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion && follow_mouse:
		global_position = get_global_mouse_position() - mouse_offset

func _on_drag_button_down() -> void:
	mouse_offset = get_global_mouse_position() - global_position
	follow_mouse = true

func _on_drag_button_up() -> void:
	follow_mouse = false


func _on_body_child_entered_tree(node : Node) -> void:
	if node.has_method("set_content"):
		node.set_content()
