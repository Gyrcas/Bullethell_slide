extends StaticBody2D
class_name Boss1

@onready var laser_attack : LaserAttack = $laser_attack

func _ready() -> void:
	laser_attack.rotation_degrees -= rotation_degrees
	laser_attack.shoot(NodeLinker.player)



const marge_target : float = 10000


func _on_laser_attack_shot_finished(laser : LaserAttack):
	laser.shoot(NodeLinker.player)
