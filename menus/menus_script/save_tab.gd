extends Panel  

@onready var save_lbl : Label = $split/name_lbl
@onready var delete : Button = $split/delete
var save_manager : Control

func _on_delete_pressed() -> void:
	GS.delete_save(save_lbl.text)
	queue_free()

func _on_button_pressed() -> void:
	if save_manager.load_save:
		GS.load_save(save_lbl.text)
	elif save_lbl.text != GS.auto_save_name:
		save_manager.input_savename.text = save_lbl.text
