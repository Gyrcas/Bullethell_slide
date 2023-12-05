extends Resource
class_name Perk

@export var name : String = "unamed perk"
@export var perk_range : float = 1200
@export var nano_cost : float = 50
@export var nano_reload_time : int = 7

func execute(_sender : MoverEntity,_params : Dictionary = {}) -> void:
	push_warning("execute function not set for " + name)
