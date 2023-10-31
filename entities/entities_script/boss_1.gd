extends StaticBody2D
class_name Boss1

@onready var laser_hit_box : Area2D = $laser_hit_box
@onready var laser : Line2D = $laser
@onready var laser_pol : CollisionPolygon2D = $laser_hit_box/laser_pol
@onready var anim : AnimationPlayer = $anim

func _ready() -> void:
	laser_pol.rotation_degrees -= rotation_degrees
	laser.rotation_degrees -= rotation_degrees
	shoot()

const marge_target : float = 10000

func shoot() -> void:
	var player : Player = NodeLinker.player
	var point : Vector2 = laser.global_position
	var target : Vector2 = (
		point + point.direction_to(player.global_position) *
		(point.distance_to(player.global_position) + marge_target)
		- laser.global_position
	)
	var pol : PackedVector2Array = [
		-Vector2(laser.width / 2,0),
		Vector2(laser.width / 2,0),
		target + Vector2(laser.width / 2,0),
		target - Vector2(laser.width / 2,0)
	]
	laser_pol.polygon = pol
	laser.set_point_position(1,target)
	anim.play("shoot")

func _on_anim_animation_finished(anim_name : String) -> void:
	match anim_name:
		"shoot":
			for victim in laser_hit_box.get_overlapping_bodies():
				if victim.get("health"):
					victim.health -= 10
			anim.play("cooldown")
		"cooldown":
			shoot()
