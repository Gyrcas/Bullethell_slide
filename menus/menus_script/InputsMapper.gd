extends Container
class_name InputsMapper

const mouse_button_id : String = "mouseB"
const key_id : String = "key"
const joypad_btn_id : String = "jpbtn"

@export_file("*.json") var settings_file : String
var grid : GridContainer = GridContainer.new()

const event_pairing : Dictionary = {
	"down":"ui_down",
	"up":"ui_up",
	"left":"ui_left",
	"right":"ui_right",
	"interact":"ui_accept"
}

var changed : bool = false : set = set_changed
signal inputs_changed

func set_changed(value : bool) -> void:
	changed = value
	inputs_changed.emit()

func create_key(key : InputEvent, input : String) -> HSplitContainer:
	var split : HSplitContainer = HSplitContainer.new()
	split.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
	split.split_offset = 10000
	var key_lbl : Label = Label.new()
	key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	split.add_child(key_lbl)
	var sup_btn : Button = Button.new()
	sup_btn.text = "x"
	sup_btn.connect("pressed",remove_input.bind(input,key))
	split.add_child(sup_btn)
	if key is InputEventKey:
		key_lbl.text = key.as_text_keycode()
	elif key is InputEventMouseButton:
		match key.button_index:
			MOUSE_BUTTON_LEFT:
				key_lbl.text = "left click mouse"
			MOUSE_BUTTON_RIGHT:
				key_lbl.text = "right click mouse"
	elif key is InputEventJoypadButton:
		key_lbl.text = key.as_text()
	return split

func save_to_file() -> void:
	if !settings_file:
		push_error("No setting file")
		return
	var settings : Dictionary = JSON.parse_string(FS.read(settings_file))
	if !settings.has("inputs"):
		settings["inputs"] = {}
	var actions : Array = get_actions()
	for action in actions:
		var inputs : Array = InputMap.action_get_events(action)
		settings["inputs"][action] = []
		for input in inputs:
			if input is InputEventKey:
				settings["inputs"][action].append(key_id + str(input.keycode))
			elif input is InputEventMouseButton:
				settings["inputs"][action].append(mouse_button_id + str(input.button_index))
			elif input is InputEventJoypadButton:
				settings["inputs"][action].append(joypad_btn_id + str(input.button_index))
	FS.write(settings_file,JSON.stringify(settings))
	
func load_file() -> void:
	if !settings_file:
		push_error("No setting file")
		return
	var settings : Dictionary = JSON.parse_string(FS.read(settings_file))
	if !settings.has("inputs"):
		InputMap.load_from_project_settings()
		settings["inputs"] = {}
		save_to_file()
	for input in settings.inputs.keys():
		if !InputMap.has_action(input):
			InputMap.add_action(input)
		InputMap.action_erase_events(input)
		if event_pairing.has(input):
			InputMap.action_erase_events(event_pairing[input])
			
		for key in settings.inputs[input]:
			var input_event : InputEvent
			if key_id in key:
				input_event = InputEventKey.new()
				input_event.keycode = int(key.split(key_id)[1])
			elif mouse_button_id in key:
				input_event = InputEventMouseButton.new()
				input_event.button_index = int(key.split(mouse_button_id)[1])
			elif joypad_btn_id in key:
				input_event = InputEventJoypadButton.new()
				input_event.button_index = int(key.split(joypad_btn_id)[1])
			InputMap.action_add_event(input,input_event)
			if event_pairing.has(input):
				InputMap.action_add_event(event_pairing[input],input_event)
	load_inputs()

func get_actions() -> PackedStringArray:
	var actions : PackedStringArray = InputMap.get_actions()
	var new_actions : PackedStringArray = []
	for action in actions:
		if not "ui_" in action:
			new_actions.append(action)
	return new_actions

func load_inputs() -> void:
	for child in grid.get_children():
		child.queue_free()
	var actions : PackedStringArray = get_actions()
	var inputs : Dictionary = {}
	grid.columns = 1
	for action in actions:
		inputs[action] = InputMap.action_get_events(action)
		if inputs[action].size() > grid.columns:
			grid.columns = inputs[action].size()
	grid.columns += 1
	for input in inputs.keys():
		var input_size : int = 0
		var input_keys : Array[Control] = []
		for key in inputs[input]:
			if not (key is InputEventKey && "(Unset)" in key.as_text_keycode()):
				input_keys.append(create_key(key,input))
				input_size += 1
		var split : HSplitContainer = HSplitContainer.new()
		split.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
		split.split_offset = 10000
		var input_lbl : Label = Label.new()
		input_lbl.text = input.replace("_"," ")
		split.add_child(input_lbl)
		var input_btn : Button = Button.new()
		input_btn.text = "Add"
		input_btn.connect("pressed",add_input.bind(input))
		split.add_child(input_btn)
		grid.add_child(split)
		split.name = input
		for input_key in input_keys:
			grid.add_child(input_key)
		while input_size < grid.columns - 1:
			grid.add_child(Control.new())
			input_size += 1
	var reset_btn : Button = Button.new()
	reset_btn.text = "Reset"
	reset_btn.connect("pressed",on_reset_btn_pressed)
	grid.add_child(reset_btn)
	var save_btn : Button = Button.new()
	save_btn.text = "Save"
	save_btn.connect("pressed",on_save_btn_pressed)
	grid.add_child(save_btn)

var waiting_input : bool = false
var action_add : String = ""

func add_input(action : String) -> void:
	waiting_input = true
	action_add = action.replace(" ","_")

func _input(event : InputEvent) -> void:
	if !waiting_input:
		return
	if event is InputEventKey || event is InputEventJoypadButton:
		waiting_input = false
		InputMap.action_add_event(action_add,event)
		if event_pairing.has(action_add):
			InputMap.action_add_event(event_pairing[action_add],event)
		load_inputs()
	else:
		print(event.as_text())

func on_save_btn_pressed() -> void:
	save_to_file()
	changed = false

func on_reset_btn_pressed() -> void:
	InputMap.load_from_project_settings()
	load_inputs()

func remove_input(action : String,input : InputEvent) -> void:
	InputMap.action_erase_event(action,input)
	if event_pairing.has(action):
		InputMap.action_erase_event(event_pairing[action],input)
	changed = true
	load_inputs()

func _ready() -> void:
	var scroll : ScrollContainer = ScrollContainer.new()
	scroll.size = size
	add_child(scroll)
	grid.size = size
	scroll.add_child(grid)
	load_file()

