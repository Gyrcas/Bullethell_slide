extends MoverEntity
class_name Boss1

func _ready() -> void:
	imunities = ["normal"]
	for child in $laser.get_children():
		child.rotation_degrees -= rotation_degrees
		child.speed = randf_range(1,3)
		child.shoot(Global.player)

func _on_laser_attack_shot_finished(laser : LaserAttack):
	laser.speed = randf_range(1,3)
	laser.shoot(Global.player)

func _on_anim_animation_finished(_anim_name : String) -> void:
	pass
