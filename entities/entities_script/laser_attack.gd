extends Node2D
class_name LaserAttack

@onready var laser : Line2D = $laser
@onready var laser_pol : CollisionPolygon2D = $laser_hit_box/laser_pol
@onready var anim : AnimationPlayer = $anim
@onready var laser_hit_box : Area2D = $laser_hit_box

@export var marge_target : float = 10000
@export var damage : float = 1
@export var speed : float = 1 : set = set_speed
@export var width : float = 100 : set = set_width

func set_width(value : float) -> void:
	width = value
	if laser:
		laser.width = width

func set_speed(value : float) -> void:
	speed = value
	if anim:
		anim.speed_scale = speed

func _ready() -> void:
	anim.speed_scale = speed
	laser.width = width

signal shot_finished

func shoot(target : Node2D) -> void:
	var point : Vector2 = laser.global_position
	var target_pos : Vector2 = (
		point + point.direction_to(target.global_position) *
		(point.distance_to(target.global_position) + marge_target)
		- laser.global_position
	)
	var pol : PackedVector2Array = [
		-Vector2(laser.width / 4,0),
		Vector2(laser.width / 4,0),
		target_pos + Vector2(laser.width / 4,0),
		target_pos - Vector2(laser.width / 4,0)
	]
	laser_pol.polygon = pol
	laser.set_point_position(1,target_pos)
	anim.play("shoot")

func tween_width(end_value : float,time : float) -> Tween:
	var tween : Tween = create_tween()
	tween.tween_property(laser,"width",end_value, time / speed)
	tween.play()
	return tween

func grow_width() -> void:
	laser.width = 0
	tween_width(width / 5, 0.6)

func shrink_grow_width() -> void:
	var tween : Tween = tween_width(0, 0.2)
	tween.tween_callback(tween_width.bind(width,0.1))

func _on_anim_animation_finished(anim_name : String) -> void:
	match anim_name:
		"shoot":
			for victim in laser_hit_box.get_overlapping_bodies():
				if victim.get("health"):
					victim.health -= damage
			anim.play("cooldown")
		"cooldown":
			shot_finished.emit(self)
