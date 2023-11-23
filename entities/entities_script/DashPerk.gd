extends Perk
class_name DashPerk

@export var damage : float = 10
var damage_types : PackedStringArray = ["perforating"]

func _init() -> void:
	name = "Dash"

func execute(sender : MoverEntity, params : Dictionary = {}) -> void:
	var ray : RayCast2D = RayCast2D.new()
	ray.top_level = true
	ray.global_position = sender.global_position
	ray.target_position = params.target - sender.global_position
	sender.add_child(ray)
	apply_cost(sender)
	move.call_deferred(sender,params,ray)

func move(sender : MoverEntity,params : Dictionary, ray : RayCast2D) -> void:
	while ray.is_colliding():
		var collider : Node = ray.get_collider()
		if collider is MoverEntity:
			collider.apply_damage(damage,damage_types)
		elif collider is StaticBody2D:
			params.target = ray.get_collision_point()
			break
		ray.add_exception(collider)
		ray.force_raycast_update()
	sender.col.disabled = true
	var sound_id : String = AudioPlayer.play("sounds/dash.wav",false)
	AudioPlayer.set_bus_by_name(sound_id,"VFX")
	AudioPlayer.set_position(sound_id,sender.global_position)
	AudioPlayer.set_pitch(sound_id,randf_range(0.8,1.2))
	var tween : Tween = sender.create_tween()
	tween.tween_property(sender,"global_position",params.target,0.1)
	tween.tween_callback((func():sender.col.disabled = false))
	ray.queue_free()
