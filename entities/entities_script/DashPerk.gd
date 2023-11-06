extends Perk
class_name DashPerk

func _init() -> void:
	name = "Dash"

func execute(sender : MoverEntity, params : Dictionary = {}) -> void:
	var ray : RayCast2D = RayCast2D.new()
	ray.top_level = true
	ray.global_position = sender.global_position
	ray.target_position = params.target
	sender.add_child(ray)
	apply_cost(sender)
	sender.col.disabled = true
	var tween : Tween = sender.create_tween()
	tween.tween_property(sender,"global_position",params.target,0.1)
	tween.tween_callback((func():sender.col.disabled = false))
	tween.play()
	ray.queue_free()
