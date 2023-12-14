extends PauseMenuView

var settings_file : String = await NodeLinker.request_resource("settings.json",true)
@onready var inputs : Button = $center/vbox/inputs
@onready var window_type : OptionButton = $center/vbox/window_type
@onready var use_directional_turn_btn : CheckButton = $center/vbox/use_directional_turn

func on_back_menu() -> void:
	if pause_menu.views.get_node_or_null("main"):
		pause_menu.change_view("main")
	else:
		pause_menu.visible = false
		get_tree().paused = false

func _ready() -> void:
	use_directional_turn_btn.button_pressed = Global.use_directional_turn
	var settings : Dictionary = JSON.parse_string(FS.read(settings_file))
	if settings.has("window_type"):
		window_type.selected = settings.window_type

func _on_inputs_pressed() -> void:
	pause_menu.change_view("inputs")

func open_close(opening : bool) -> void:
	if opening:
		inputs.grab_focus()

func _on_window_type_item_selected(index : int) -> void:
	var settings : Dictionary = JSON.parse_string(FS.read(settings_file))
	settings["window_type"] = index
	FS.write(settings_file,JSON.stringify(settings))
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func _on_tuto_pressed() -> void:
	pause_menu.change_view("menu_tuto")


func _on_use_directional_turn_toggled(button_pressed : bool) -> void:
	Global.use_directional_turn = button_pressed
	var settings : Dictionary = JSON.parse_string(FS.read(settings_file))
	settings["use_directional_turn"] = button_pressed
	FS.write(settings_file,JSON.stringify(settings))
