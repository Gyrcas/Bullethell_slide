extends CharacterBody2D
class_name Bullet

@onready var sprite : Polygon2D = $sprite

var death_particles_scene : PackedScene = NodeLinker.request_resource("death_particles.tscn")

var nano : int = 10

var sender : Node2D : set = set_sender
@export var ignore_sender : bool = true : set = set_ignore_sender
func set_ignore_sender(value : bool) -> void:
	ignore_sender = value
	if sender:
		if ignore_sender:
			add_collision_exception_with(sender)
		else:
			remove_collision_exception_with(sender)
@export var speed : float = 2.5
@export var max_speed : float = 15
@export var turn_speed : float = 10
@export var target_position : Vector2 = Vector2(0,0)
@export var target_node : Node2D
@export var damage : float = 1
@export var precision : float = 0.05

func assign(bullet : BulletRes) -> Bullet:
	speed = bullet.speed
	max_speed = bullet.max_speed
	turn_speed = bullet.turn_speed
	target_position = bullet.target_position
	target_node = bullet.target_node
	damage = bullet.damage
	precision = bullet.precision
	return self

func set_sender(value : Node2D) -> void:
	if sender:
		remove_collision_exception_with(sender)
		if sender.has_signal("target_changed") && sender.is_connected("target_changed",on_change_target):
			sender.disconnect("target_changed",on_change_target)
		if sender.is_connected("died",die):
			sender.disconnect("died",die)
		sender.nano += nano
	sender = value
	if sender:
		sender.nano -= nano
		if sender.has_signal("target_changed"):
			sender.connect("target_changed",on_change_target)
		if !sender.is_connected("died",die):
			sender.connect("died",die)
		if ignore_sender:
			add_collision_exception_with(sender)

func _ready() -> void:
	set_sender(sender)

func die() -> void:
	if sender != null:
		sender.nano += nano
	var particles : DeathParticles = death_particles_scene.instantiate()
	particles.global_position = global_position
	particles.lifetime = 0.5
	particles.modulate = sprite.color
	get_parent().add_child(particles)
	queue_free()

func _physics_process(delta : float) -> void:
	if !target_node:
		target_node = null
	if target_node:
		target_position = target_node.global_position
	var angle_target : float = get_angle_to(target_position)
	var turn : int = angle_target / abs(angle_target)
	rotate(turn * turn_speed * delta)
	velocity += global_transform.x * speed * delta
	velocity = velocity.lerp(global_transform.x * (velocity / velocity.normalized()),0.1 * precision)
	if velocity.x / velocity.normalized().x > max_speed:
		velocity = velocity.normalized() * max_speed
	
	var collision = move_and_collide(velocity * Engine.time_scale)
	
	if collision:
		var collider : Node2D = collision.get_collider()
		if collider.get("health"):
			collider.health -= damage
		if collider is CharacterBody2D:
			collider.velocity += velocity
		die()

func on_change_target() -> void:
	target_node = sender.target.current_target
