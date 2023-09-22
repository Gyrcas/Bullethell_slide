extends Control
class_name PauseMenu

@onready var views : Control = $views

@export var current_view : PauseMenuView 

func _ready() -> void:
	visible = false
	for view in views.get_children():
		view.pause_menu = self
		view.visible = false

func change_view(view_name : String) -> void:
	var view : Control = views.get_node_or_null(view_name)
	if !view:
		push_error("View " + view_name + " does not exist")
		return
	view.visible = true
	current_view.visible = false
	current_view = view

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("back") && !current_view.override_inputs:
		if get_tree().paused:
			if current_view.has_method("on_back_menu"):
				current_view.on_back_menu()
		elif !visible && !get_tree().paused:
			visible = true
			current_view.visible = true
			get_tree().paused = true
