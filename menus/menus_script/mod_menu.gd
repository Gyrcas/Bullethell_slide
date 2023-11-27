extends PauseMenuView

@onready var mod_list : VBoxContainer = $vbox/scroll/mod_list

func _ready() -> void:
	var mods : PackedStringArray = NodeLinker.get_mods_list()
	for mod in mods:
		var mod_tab : CheckButton = CheckButton.new()
		mod_tab.text = mod
		mod_tab.connect("pressed",toggle_mod.bind(mod_tab))
		mod_list.add_child(mod_tab)

func _on_apply_pressed() -> void:
	NodeLinker.load_mods()

func toggle_mod(mod_tab : CheckButton) -> void:
	if mod_tab.button_pressed:
		if !NodeLinker.active_mods.has(mod_tab.text):
			NodeLinker.active_mods.append(mod_tab.text)
	else:
		NodeLinker.active_mods.erase(mod_tab.text)
