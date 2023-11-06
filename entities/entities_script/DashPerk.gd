extends Perk
class_name DashPerk

func _init() -> void:
	name = "Dash"

func execute(sender : MoverEntity, params : Dictionary = {}) -> void:
	var ray : RayCast2D = RayCast2D.new()
	ray.top_level = true
	ray.global_position = params.position
	ray.target_position = params.target
	sender.add_child(ray)
	sender.global_position = params.position
	apply_cost(sender)
	ray.queue_free()
	print("test")
