extends Node2D
class_name LaserAttack

@onready var laser : Line2D = $laser
@onready var laser_pol : CollisionPolygon2D = $laser_hit_box/laser_pol
@onready var anim : AnimationPlayer = $anim
@onready var laser_hit_box : Area2D = $laser_hit_box

@export var marge_target : float = 10000
@export var damage : float = 1
@export var speed : float = 1 : set = set_speed

func set_speed(value : float) -> void:
	speed = value
	if anim:
		anim.speed_scale = speed

func _ready() -> void:
	anim.speed_scale = speed

signal shot_finished

func shoot(target : Node2D) -> void:
	var point : Vector2 = laser.global_position
	var target_pos : Vector2 = (
		point + point.direction_to(target.global_position) *
		(point.distance_to(target.global_position) + marge_target)
		- laser.global_position
	)
	var pol : PackedVector2Array = [
		-Vector2(laser.width / 2,0),
		Vector2(laser.width / 2,0),
		target_pos + Vector2(laser.width / 2,0),
		target_pos - Vector2(laser.width / 2,0)
	]
	laser_pol.polygon = pol
	laser.set_point_position(1,target_pos)
	anim.play("shoot")

func _on_anim_animation_finished(anim_name : String) -> void:
	match anim_name:
		"shoot":
			for victim in laser_hit_box.get_overlapping_bodies():
				if victim.get("health"):
					victim.health -= damage
			anim.play("cooldown")
		"cooldown":
			shot_finished.emit(self)
