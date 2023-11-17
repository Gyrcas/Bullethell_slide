extends PauseMenuView

func on_back_menu() -> void:
	pause_menu.change_view("options")
	
@onready var input_mapper : InputsMapper = $InputsMapper

func _ready() -> void:
	input_mapper.connect("inputs_changed",on_inputs_changed)

func on_inputs_changed() -> void:
	override_inputs = input_mapper.changed

func open_close(opening : bool) -> void:
	if opening:
		input_mapper.save_btn.grab_focus()
