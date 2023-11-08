extends RichTextLabel
class_name Debug

var mouse_offset : Vector2 = Vector2.ZERO
var mouse_down : bool = false

func memory_info_mb() -> String:
	var mem : Dictionary = OS.get_memory_info()
	var string : String = ""
	for i in mem.keys():
		string += "\n	"+i+":"
		for j in range(10-i.length()):
			string += "  "
		string += str(mem[i] / 1000000)+"mb"
	return string

func _physics_process(_delta) -> void:
	if !visible:
		return
	text = (
		"FPS:			"+str(Engine.get_frames_per_second())+"\n"+ 
		"Static Memory:	"+str(OS.get_static_memory_usage()/1000000)+"mb\n"+
		"Peak Memory:	"+str(OS.get_static_memory_peak_usage()/1000000)+"mb\n"+
		"Memory infos:	"+memory_info_mb()+"\n"+
		"Nodes count:	"+str(get_tree().get_node_count())+"\n"+
		"tweens count:	"+str(get_tree().get_processed_tweens().size())
	)

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion && mouse_down:
		global_position = get_global_mouse_position() - mouse_offset
	if event.is_action_pressed("debug"):
		visible = !visible

func _ready() -> void:
	fit_content = true
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF
	visible = false

func _gui_input(event : InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		mouse_down = true
		mouse_offset = get_global_mouse_position() - global_position
	elif event.is_action_released("left_click"):
		mouse_down = false
