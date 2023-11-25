@tool
extends VSplitContainer
class_name AudioBusSlider

@export var text : String = "Volume"
@export var bus_name : String = "Master" : set = set_bus_name
@export var min_range : float = -40
@export var max_range : float = 10
var settings_file : String = "" if Engine.is_editor_hint() else NodeLinker.request_resource("settings.json",true)
var bus_id : int = -1
var slider : HSlider

func grab_focus_slider() -> void:
	slider.grab_focus()

func set_bus_name(value : String) -> void:
	bus_name = value
	bus_id = -1
	var new_id : Variant = AudioServer.get_bus_index(bus_name)
	if new_id != null:
		bus_id = new_id
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	if bus_id == -1:
		warnings.append("Bus \""+bus_name+"\" does not exist")
	return warnings

func on_focus() -> void:
	slider.grab_focus()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var settings : Dictionary = JSON.parse_string(FS.read(settings_file))
	if !settings.get("volume"):
		settings["volume"] = {}
	if !settings.volume.get(bus_name):
		settings.volume[bus_name] = 0
	focus_mode = Control.FOCUS_ALL
	bus_id = AudioServer.get_bus_index(bus_name)
	if bus_id == null:
		return
	var lbl : Label = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(lbl)
	connect("focus_entered",on_focus)
	slider = HSlider.new()
	slider.focus_neighbor_bottom = "../" + str(focus_neighbor_bottom)
	slider.focus_neighbor_top = "../" + str(focus_neighbor_top)
	slider.min_value = min_range
	slider.max_value = max_range
	slider.value = AudioServer.get_bus_volume_db(bus_id)
	slider.connect("value_changed",change_volume)
	add_child(slider)

func change_volume(value : float) -> void:
	AudioServer.set_bus_volume_db(bus_id,value)
	var settings : Dictionary = JSON.parse_string(FS.read(settings_file))
	settings.volume[bus_name] = value
	FS.write(settings_file,JSON.stringify(settings))
		
