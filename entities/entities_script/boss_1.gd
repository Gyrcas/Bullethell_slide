extends MoverEntity
class_name Boss1

const distant_slow_mo : float = 3000
const use_slow_mo : bool = true

func _ready() -> void:
	imunities = ["normal"]
	for child in $laser.get_children():
		child.rotation_degrees -= rotation_degrees
		child.speed = randf_range(1,3)
		child.shoot(Global.player)

func _physics_process(_delta : float) -> void:
	if use_slow_mo && Engine.time_scale > 0.1 && !dying && !Global.player.dying:
		Global.set_time_scale(
			clampf(
				global_position.distance_to(
					Global.player.global_position
				) / distant_slow_mo, 0.2, 1
			)
		)
	elif Global.player.dying:
		Global.set_time_scale(1)
	

func _on_laser_attack_shot_finished(laser : LaserAttack):
	laser.speed = randf_range(1,3)
	laser.shoot(Global.player)

func _on_anim_animation_finished(_anim_name : String) -> void:
	pass
