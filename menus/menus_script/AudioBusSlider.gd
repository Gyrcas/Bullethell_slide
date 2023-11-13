@tool
extends VSplitContainer
class_name AudioBusSlider

@export var text : String = "Volume"
@export var bus_name : String = "Master" : set = set_bus_name
@export var min_range : float = -40
@export var max_range : float = 10
@export_file("*.json") var settings_file : String
var bus_id : int = -1
var slider : HSlider

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

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	bus_id = AudioServer.get_bus_index(bus_name)
	if bus_id == null:
		return
	var lbl : Label = Label.new()
	lbl.text = text
	add_child(lbl)
	slider = HSlider.new()
	slider.min_value = min_range
	slider.max_value = max_range
	slider.value = AudioServer.get_bus_volume_db(bus_id)
	slider.connect("drag_started",on_slider_started)
	slider.connect("drag_ended",on_slider_ended)
	add_child(slider)

var changing_volume : bool = false

func _process(_delta : float) -> void:
	if changing_volume:
		AudioServer.set_bus_volume_db(bus_id,slider.value)

func on_slider_started() -> void:
	changing_volume = true

func on_slider_ended(_same : bool) -> void:
	changing_volume = false
	AudioServer.set_bus_volume_db(bus_id,slider.value)
	if settings_file:
		var settings : Dictionary = JSON.parse_string(FS.read(settings_file))
		if !settings.has("volume"):
			settings["volume"] = {}
		settings.volume[bus_name] = slider.value
		FS.write(settings_file,JSON.stringify(settings))