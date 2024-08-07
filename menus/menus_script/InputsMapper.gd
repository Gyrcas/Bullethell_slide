extends Container
class_name InputsMapper

const mouse_button_id : String = "mouseB"
const key_id : String = "key"
const joypad_btn_id : String = "jpbtn"

var settings_file : String = await NodeLinker.request_resource("settings.json",true)
var grid : GridContainer = GridContainer.new()
var save_btn : Button

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

const joypad_motion_id : String = "jpmtn"

func create_key(key : InputEvent, input : String) -> HSplitContainer:
	var split : HSplitContainer = HSplitContainer.new()
	split.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
	split.split_offset = 10000
	var key_lbl : Label = Label.new()
	key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	split.add_child(key_lbl)
	var sup_btn : Button = Button.new()
	sup_btn.name = "del"
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
	elif key is InputEventJoypadButton || key is InputEventJoypadMotion:
		key_lbl.text = key.as_text()
	return split

func save_to_file() -> void:
	var settings : Dictionary = JSON.parse_string(FS.read(settings_file))
	if !settings.has("inputs"):
		settings["inputs"] = {}
	var actions : Array = InputsMapper.get_actions()
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
			elif input is InputEventJoypadMotion:
				settings["inputs"][action].append(joypad_motion_id + str(input.axis) + "_" + str(input.axis_value))
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
				input_event.device = 0
			elif joypad_motion_id in key:
				input_event = InputEventJoypadMotion.new()
				var split : PackedStringArray = key.split(joypad_motion_id)[1].split("_")
				input_event.axis = int(split[0])
				input_event.axis_value = float(split[1])
				input_event.device = 0
			InputMap.action_add_event(input,input_event)
	load_inputs()

static func get_actions() -> PackedStringArray:
	var actions : PackedStringArray = InputMap.get_actions()
	var new_actions : PackedStringArray = []
	for action in actions:
		if not "ui_" in action:
			new_actions.append(action)
	return new_actions

func load_inputs() -> void:
	InputMap.load_from_project_settings()
	for child in grid.get_children():
		child.queue_free()
	var actions : PackedStringArray = InputsMapper.get_actions()
	var inputs : Dictionary = {}
	grid.columns = 1
	for action in actions:
		inputs[action] = InputMap.action_get_events(action)
		if inputs[action].size() > grid.columns:
			grid.columns = inputs[action].size()
	grid.columns += 1
	for input in inputs.keys():
		var input_size : int = 0
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
		var previous_del : Button
		for key in inputs[input]:
			if not (key is InputEventKey && "(Unset)" in key.as_text_keycode()):
				var new_key : HSplitContainer = create_key(key,input)
				grid.add_child(new_key)
				var del_btn : Button = new_key.get_node("del")
				input_size += 1
				if previous_del:
					del_btn.focus_neighbor_left = del_btn.get_path_to(previous_del)
					previous_del.focus_neighbor_right = previous_del.get_path_to(del_btn)
				else:
					del_btn.focus_neighbor_left = del_btn.get_path_to(input_btn)
					input_btn.focus_neighbor_right = input_btn.get_path_to(del_btn)
				previous_del = del_btn
				if event_pairing.has(input) && !( key is InputEventJoypadButton && key.button_index in [1,11,12,13,14]):
					InputMap.action_add_event(event_pairing[input],key)
		while input_size < grid.columns - 1:
			grid.add_child(Control.new())
			input_size += 1
	var reset_btn : Button = Button.new()
	reset_btn.text = "Reset"
	reset_btn.connect("pressed",on_reset_btn_pressed)
	grid.add_child(reset_btn)
	save_btn = Button.new()
	save_btn.text = "Save"
	save_btn.connect("pressed",on_save_btn_pressed)
	grid.add_child(save_btn)
	save_btn.grab_focus()

var waiting_input : bool = false
var action_add : String = ""

func add_input(action : String) -> void:
	add_timer.start(0.1)
	await add_timer.timeout
	waiting_input = true
	action_add = action.replace(" ","_")

func _input(event : InputEvent) -> void:
	if !waiting_input:
		return
	if !is_valid_event_device(event):
		return
	if event is InputEventKey || event is InputEventJoypadButton || event is InputEventJoypadMotion:
		add_timer.start(0.1)
		await add_timer.timeout
		waiting_input = false
		InputMap.action_add_event(action_add,event)
		if event_pairing.has(action_add):
			InputMap.action_add_event(event_pairing[action_add],event)
		load_inputs()

func on_save_btn_pressed() -> void:
	save_to_file()
	changed = false

func on_reset_btn_pressed() -> void:
	InputMap.load_from_project_settings()
	load_inputs()

func is_valid_event_device(event : InputEvent) -> bool:
	return !(event is InputEventJoypadButton || event is InputEventJoypadMotion) || event.device == 0

func remove_input(action : String,input : InputEvent) -> void:
	InputMap.action_erase_event(action,input)
	if event_pairing.has(action):
		InputMap.action_erase_event(event_pairing[action],input)
	changed = true
	load_inputs()

var add_timer : Timer = Timer.new()

func _ready() -> void:
	add_child(add_timer)
	var scroll : ScrollContainer = ScrollContainer.new()
	scroll.size = size
	add_child(scroll)
	grid.size = size
	scroll.add_child(grid)
	load_file()

