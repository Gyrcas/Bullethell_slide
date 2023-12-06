extends MoverEntity
class_name Boss1
# First boss. Use tscn file

# Distance from where the time start to slow
const distant_slow_mo : float = 3000

const use_slow_mo : bool = true

func activate() -> void:
	for child in $laser.get_children():
		child.victim_condition = func(target : MoverEntity):
			return target is Player
		child.rotation_degrees -= rotation_degrees
		child.speed = randf_range(1,3)
		child.shoot(Global.player.global_position)

#Prevent boss from being killed by normal attacks. Must use dash
func _ready() -> void:
	imunities = ["normal"]

func _physics_process(_delta : float) -> void:
	#Change time scale (slow mo) with distance from boss
	if use_slow_mo && Engine.time_scale > 0.1 && !dying && !Global.player.dying:
		Global.set_time_scale(
			clampf(
				global_position.distance_to(
					Global.player.global_position
				) / distant_slow_mo, 0.2, 1
			) , true, 3
		)
	elif Global.player.dying:
		Global.set_time_scale(1,true,3)
	

#When laser shot finished, shoot again
func _on_laser_attack_shot_finished(laser : LaserAttack):
	laser.speed = randf_range(1,3)
	laser.shoot(Global.player.global_position)

func _on_anim_animation_finished(_anim_name : String) -> void:
	pass
