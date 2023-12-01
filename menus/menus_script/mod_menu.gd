extends PauseMenuView

@onready var mod_list : VBoxContainer = $vbox/scroll/split/mod_list
@onready var buttons : VBoxContainer = $vbox/scroll/split/buttons
var active_mods : Array = NodeLinker.active_mods.duplicate()

func _ready() -> void:
	for child in mod_list.get_children():
		child.queue_free()
	var mods : PackedStringArray = NodeLinker.get_mods_list()
	for mod in mods:
		var mod_tab : CheckButton = CheckButton.new()
		mod_tab.text = mod
		if active_mods.has(mod):
			mod_tab.button_pressed = true
		mod_tab.connect("pressed",change_mod.bind(mod_tab))
		mod_list.add_child(mod_tab)
		
		var split : HSplitContainer = HSplitContainer.new()
		split.dragger_visibility = SplitContainer.DRAGGER_HIDDEN_COLLAPSED
		buttons.add_child(split)
		
		var idx : int = mod_tab.get_index()
		
		var button : Button = Button.new()
		button.text = "up"
		button.connect("pressed",move.bind(idx,idx - 1))
		split.add_child(button)
		
		button = Button.new()
		button.text = "down"
		button.connect("pressed",move.bind(idx,idx + 1))
		split.add_child(button)

func change_mod(check : CheckButton) -> void:
	if check.button_pressed:
		if !active_mods.has(check.text):
			move(check.get_index(),active_mods.size(),true)
			active_mods.append(check.text)
	else:
		active_mods.erase(check.text)
		move(check.get_index(),active_mods.size(),true)

func move(from : int, to : int, ignore_active : bool = false) -> void:
	var check : CheckButton = mod_list.get_children()[from]
	if (to < 0 ||
		(
			(!active_mods.has(check.text) || 
			to > active_mods.size() - 1) 
			&& !ignore_active)
		):
		return
	mod_list.move_child(check,to)

func _on_apply_pressed() -> void:
	var old_mods : Array = NodeLinker.active_mods
	NodeLinker.active_mods = []
	for mod_tab in mod_list.get_children():
		if mod_tab.button_pressed:
			NodeLinker.active_mods.append(mod_tab.text)
	NodeLinker.apply_mods(old_mods)
	get_tree().paused = false
	get_tree().reload_current_scene()
