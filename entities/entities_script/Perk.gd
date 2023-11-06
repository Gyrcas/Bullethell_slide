extends Resource
class_name Perk

@export var name : String = "unamed perk"
@export var range : float = 1200
@export var nano_cost : float = 10
@export var nano_reload_time : float = 3

func execute(sender : MoverEntity,params : Dictionary = {}) -> void:
	push_warning("execute function not set")

func apply_cost(sender : MoverEntity) -> void:
	sender.nano -= nano_cost
	var tree : SceneTree = sender.get_tree()
	for i in nano_reload_time:
		await tree.create_timer(1).timeout
		sender.nano += nano_cost / nano_reload_time
