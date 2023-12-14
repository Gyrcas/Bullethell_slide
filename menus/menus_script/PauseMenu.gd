extends Control
class_name PauseMenu

@onready var views : Control = $views

@export var views_array : Array[String] = []

@export var open_with_back : bool = true

var current_view : Control

func _ready() -> void:
	visible = false
	for i in views_array.size():
		var scene : PackedScene = await NodeLinker.request_resource(views_array[i])
		var v : PauseMenuView = scene.instantiate()
		if i == 0:
			current_view = v
		v.pause_menu = self
		views.add_child(v)
		v.visible = false

func open(view_name : String = "", params : Dictionary = {}) -> void:
	visible = true
	get_tree().paused = true
	if view_name == "":
		current_view = views.get_child(0)
		current_view.visible = true
	else:
		change_view(view_name,params)

func change_view(view_name : String, params : Dictionary = {}) -> void:
	var view : Control = views.get_node_or_null(view_name)
	if !view:
		push_error("View " + view_name + " does not exist")
		return
	if !params.is_empty():
		for key in params.keys():
			view.set(key,params[key]) 
	current_view.visible = false
	view.visible = true
	current_view = view

func _input(event : InputEvent) -> void:
	if current_view && !current_view.override_inputs:
		if get_tree().paused && event.is_action_pressed("back"):
			if current_view.has_method("on_back_menu"):
				current_view.on_back_menu()
		elif event.is_action_pressed("pause_menu") && open_with_back:
			if !visible && !get_tree().paused:
				open()
			elif visible && get_tree().paused && current_view.can_close_with_open_menu:
				current_view.on_back_menu()
			

signal closed

func _set(property : StringName, value : Variant) -> bool:
	if property == "visible" && !value:
		closed.emit()
	return false
