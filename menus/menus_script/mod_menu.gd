extends PauseMenuView

@onready var mod_list : VBoxContainer = $vbox/scroll/mod_list

func _ready() -> void:
	var mods : PackedStringArray = NodeLinker.get_mods_list()
	for mod in mods:
		var mod_tab : CheckButton = CheckButton.new()
		mod_tab.text = mod
		if NodeLinker.active_mods.has(mod):
			mod_tab.button_pressed = true
		mod_list.add_child(mod_tab)

func _on_apply_pressed() -> void:
	var old_mods : Array = NodeLinker.active_mods
	NodeLinker.active_mods = []
	for mod_tab in mod_list.get_children():
		if mod_tab.button_pressed:
			NodeLinker.active_mods.append(mod_tab.text)
	print(old_mods)
	NodeLinker.apply_mods(old_mods)
