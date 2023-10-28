extends PauseMenuView

var save_scene : PackedScene = NodeLinker.request_resource("save_tab.tscn")
@onready var saves : VBoxContainer = $vbox/scroll/saves
@onready var bottom : HSplitContainer = $vbox/bottom
@onready var input_savename : TextEdit = $vbox/bottom/input_savename

var load_save : bool = true : set = set_load_save
var back_to_view : String = "main"
var save_position : Vector2 = Vector2.ZERO

func set_load_save(value : bool) -> void:
	load_save = value
	bottom.visible = !value

func on_back_menu() -> void:
	if back_to_view == "":
		pause_menu.visible = false
		get_tree().paused = false
	else:
		pause_menu.change_view(back_to_view)

func load_saves() -> void:
	var files : Array = FS.read_dir(GS.save_location)
	UT.remove_children(saves)
	for file in files:
		create_save_tab(file)

func create_save_tab(file : String, base_file : bool = true) -> void:
	var save : Panel = save_scene.instantiate()
	save.save_manager = self
	saves.add_child(save)
	save.save_lbl.text = file.get_file().replace("."+file.get_extension(),"") if base_file else file
	if save.save_lbl.text == GS.auto_save_name:
		save.delete.queue_free()

func _ready() -> void:
	load_saves()
	if !pause_menu.views.get_node_or_null("main"):
		load_save = false


func _on_save_button_pressed() -> void:
	var savenames : PackedStringArray = []
	for save in saves.get_children():
		savenames.append(save.save_lbl.text)
	if !savenames.has(input_savename.text):
		GS.save(input_savename.text)
		create_save_tab(input_savename.text,false)
		input_savename.text = ""
