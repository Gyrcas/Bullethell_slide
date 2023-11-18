extends PauseMenuView

var save_scene : PackedScene = NodeLinker.request_resource("save_tab.tscn")
@onready var saves : VBoxContainer = $vbox/scroll/saves
@onready var bottom : HSplitContainer = $vbox/bottom
@onready var input_savename : LineEdit = $vbox/bottom/input_savename
@onready var save_button : Button = $vbox/bottom/save_button

var load_save : bool = true : set = set_load_save
var back_to_view : String = "main"
var save_position : Vector2 = Vector2.ZERO

func set_load_save(value : bool) -> void:
	load_save = value
	bottom.visible = !value

func on_back_menu() -> void:
	if get_viewport().gui_get_focus_owner() != save_button && bottom.visible:
		save_button.grab_focus()
	elif back_to_view == "":
		pause_menu.visible = false
		get_tree().paused = false
	else:
		pause_menu.change_view(back_to_view)

var previous_save : SaveTab

func load_saves() -> void:
	var files : Array = FS.read_dir(GS.save_location)
	var data : Array = []
	for child in saves.get_children():
		child.queue_free()
	for file in files:
		previous_save = create_save_tab(file)
	if !previous_save:
		return
	previous_save.button.focus_neighbor_bottom = previous_save.button.get_path_to(save_button)
	save_button.focus_neighbor_top = save_button.get_path_to(previous_save.button)
	previous_save = null

func on_save_deleted(index : int) -> void:
	var previous_tab : SaveTab = null if index == 0 else saves.get_child(index-1)
	if previous_tab:
		previous_tab.button.grab_focus()
		if previous_tab.get_index() == saves.get_child_count() - 2:
			previous_tab.button.focus_neighbor_bottom = previous_tab.button.get_path_to(save_button)
			save_button.focus_neighbor_top = save_button.get_path_to(previous_tab.button)
		else:
			var other_tab : SaveTab = saves.get_child(previous_tab.get_index() + 1)
			previous_tab.button.focus_neighbor_bottom = previous_tab.button.get_path_to(other_tab)
			other_tab.button.focus_neighbor_top = other_tab.button.get_path_to(previous_tab.button)
	elif saves.get_child_count() > 0:
		saves.get_child(0).button.grab_focus()
	else:
		save_button.grab_focus()

func create_save_tab(file : String, base_file : bool = true) -> SaveTab:
	var save : SaveTab = save_scene.instantiate()
	save.save_manager = self
	save.datetime = JSON.parse_string(FS.read(file)).datetime
	saves.add_child(save)
	save.save_lbl.text = file.get_file().replace("."+file.get_extension(),"") if base_file else file
	save.delete.connect("pressed",on_save_deleted.bind(save.get_index()))
	if previous_save:
		save.button.focus_neighbor_top = save.button.get_path_to(previous_save.button)
		previous_save.button.focus_neighbor_bottom = previous_save.button.get_path_to(save.button)
	if save.save_lbl.text == GS.auto_save_name:
		save.delete.queue_free()
		saves.move_child(save,0)
	else:
		var placed : bool = false
		for child in saves.get_children():
			if child.datetime < save.datetime && child.get_index() != 0:
				saves.move_child(save,child.get_index())
				break
	return save

func _ready() -> void:
	load_saves()
	if !pause_menu.views.get_node_or_null("main"):
		load_save = false


func _on_save_button_pressed() -> void:
	if GS.auto_save_name != input_savename.text:
		create_save_tab(GS.save(input_savename.text),false)
		input_savename.text = ""
		load_saves()

func open_close(opening : bool) -> void:
	if opening && saves.get_child_count() > 0:
		saves.get_child(0).button.grab_focus()
	else:
		save_button.grab_focus()
