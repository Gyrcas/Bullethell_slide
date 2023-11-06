extends SpaceMover
class_name Bullet

@onready var sprite : Node2D = $sprite
@onready var avoid : Area2D = $avoid

var death_particles_scene : PackedScene = NodeLinker.request_resource("death_particles.tscn")

var nano : int = 10

var sender : Node2D : set = set_sender
var ignore_sender : bool = true : set = set_ignore_sender
func set_ignore_sender(value : bool) -> void:
	ignore_sender = value
	if sender:
		if ignore_sender:
			add_collision_exception_with(sender)
		else:
			remove_collision_exception_with(sender)
var target_position : Vector2 = Vector2(0,0)
var target_node : Node2D
var damage : float = 1
var avoid_div : float = 100


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

func die() -> void:
	if sender != null:
		sender.nano += nano
	var particles : DeathParticles = death_particles_scene.instantiate()
	particles.global_position = global_position
	particles.lifetime = 0.5
	particles.modulate = sprite.color
	get_parent().add_child(particles)
	
	queue_free()

func collide(collision) -> void:
	var collider : Node2D = collision.get_collider()
	if collider.get("sender") == sender:
		add_collision_exception_with(collider)
		return
	if collider.get("health"):
		collider.health -= damage
	if collider is CharacterBody2D:
		collider.velocity += velocity
	die()

func _physics_process(delta : float) -> void:
	if !target_node:
		target_node = null
	target_position = target_node.global_position if target_node else global_position + global_transform.x * 100
	var angle_target : float = get_angle_to(target_position)
	var turn : float = angle_target / abs(angle_target)
	for body in avoid.get_overlapping_bodies():
		if body is Bullet && body != self:
			angle_target = get_angle_to(body.global_position)
			turn += -(angle_target / abs(angle_target)) / avoid_div
	clampf(turn,-1,1)
	
	var collision : Variant = do_move(1,turn,delta, velocity.x / velocity.normalized().x if velocity.x != 0 else 1.0)
	if collision:
		collide(collision)

func on_change_target() -> void:
	target_node = sender.target.current_target
