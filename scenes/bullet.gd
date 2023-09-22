extends CharacterBody2D
class_name Bullet

@onready var sprite : Polygon2D = $sprite

var death_particles_scene : PackedScene = load(NodeLinker.death_particles)

var sender : Node2D : set = set_sender
var speed : float = 2.5
var max_speed : float = 15
var turn_speed : float = 10
var target_position : Vector2 = Vector2(0,0)
var target_node : Node2D
var damage : float = 1
var precision : float = 0.05

func set_sender(value : Node2D) -> void:
	sender = value
	if sender:
		add_collision_exception_with(sender)

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
		if sender == NodeLinker.player:
			NodeLinker.player.bullets.erase(self)
		var particles : GPUParticles2D = death_particles_scene.instantiate()
		particles.global_position = collision.get_position()
		particles.lifetime = 0.3
		particles.process_material.color = sprite.color
		get_parent().add_child(particles)
		particles.emitting = true
		queue_free()
	
	
