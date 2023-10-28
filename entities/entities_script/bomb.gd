extends Bullet
class_name Bomb

func _draw() -> void:
	sprite.polygon = []
	draw_circle(Vector2.ZERO,12,Color(0,0,0))
	draw_circle(Vector2.ZERO,10,sprite.color)

var blast_zone : Area2D = Area2D.new()

func _ready() -> void:
	add_child.call_deferred(blast_zone)
	var col : CollisionShape2D = CollisionShape2D.new()
	col.shape = CircleShape2D.new()
	col.shape.radius = 300
	blast_zone.add_child.call_deferred(col)

func collide(collision) -> void:
	var collider : Node2D = collision.get_collider()
	if collider.get("sender") == sender:
		add_collision_exception_with(collider)
		return
	for body in blast_zone.get_overlapping_bodies():
		if body.get("health"):
			body.health -= damage
		if body.get("velocity") != null:
			body.velocity += global_position.direction_to(body.global_position) * 25
	die()

func die() -> void:
	if sender != null:
		sender.nano += nano
	var particles : DeathParticles = death_particles_scene.instantiate()
	particles.global_position = global_position
	particles.lifetime = 5
	if sprite:
		particles.modulate = sprite.color
	if get_parent():
		get_parent().add_child(particles)
	queue_free()
