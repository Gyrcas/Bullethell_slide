extends Control
class_name PauseMenu

@onready var views : Control = $views

@export var views_array : Array[String] = []

@export var open_with_back : bool = true

var current_view : Control

func _ready() -> void:
	visible = false
	for i in views_array.size():
		var v : PauseMenuView = NodeLinker.request_resource(views_array[i]).instantiate()
		if i == 0:
			current_view = v
		v.pause_menu = self
		views.add_child(v)
		v.visible = false

func change_view(view_name : String) -> void:
	var view : Control = views.get_node_or_null(view_name)
	if !view:
		push_error("View " + view_name + " does not exist")
		return
	view.visible = true
	current_view.visible = false
	current_view = view

func _input(event : InputEvent) -> void:
	if current_view && event.is_action_pressed("back") && !current_view.override_inputs:
		if get_tree().paused:
			if current_view.has_method("on_back_menu"):
				current_view.on_back_menu()
		elif open_with_back && !visible && !get_tree().paused:
			visible = true
			current_view.visible = true
			get_tree().paused = true
