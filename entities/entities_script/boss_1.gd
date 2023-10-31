extends StaticBody2D
class_name Boss1

func _ready() -> void:
	for child in $laser.get_children():
		child.rotation_degrees -= rotation_degrees
		child.speed = randf_range(1,3)
		child.shoot(NodeLinker.player)

func _on_laser_attack_shot_finished(laser : LaserAttack):
	laser.speed = randf_range(1,3)
	laser.shoot(NodeLinker.player)
