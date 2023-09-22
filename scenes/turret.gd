extends StaticBody2D
class_name Turret

@export var time_between_burst : float = 2.5
@export var bullet_per_burst : int = 5
@export var time_between_bullets : float = 0.1
@export var bullet_speed : float = 2.5
@export var range_angle : float = 20
@export var max_distance : float = 5000

@onready var timer_burst : Timer = $timer_burst
@onready var timer_bullet : Timer = $timer_bullet
@onready var bullet_spawn_point : Vector2 = $bullet_spawn_point.global_position
@onready var detection : RayCast2D = $detection
@onready var anim_player : AnimationPlayer = $anim_player

@export var bullet_preset : Bullet = preload(NodeLinker.bullet_scene).instantiate()

var death_particles_scene : PackedScene = preload(NodeLinker.death_particles)

var bullet_color : Color = Color(5,0,0)

@export var health : int = 2 : set = set_health

func set_health(value : int) -> void:
	if (value - health < 0 && !can_be_hurt) || health <= 0:
		return
	health = value
	if health <= 0:
		anim_player.play("death")
		timer_bullet.stop()
		timer_burst.stop()
		can_shoot = false
		var particles : GPUParticles2D = death_particles_scene.instantiate()
		particles.global_position = global_position
		particles.lifetime = 3
		get_parent().add_child(particles)
		particles.emitting = true
var can_be_hurt : bool = true

var bullet_count : int = 0
var can_shoot : bool = true

var waiting_for_burst : bool = false

func set_bullet_color(value : Color = bullet_color, bullet : Bullet = Bullet.new()) -> void:
	bullet.sprite.color = value

func _ready() -> void:
	timer_bullet.start(time_between_bullets)
	detection.rotation = -rotation

func _physics_process(_delta : float) -> void:
	detection.target_position = NodeLinker.player.global_position - detection.global_position
	if detection.get_collider() == NodeLinker.player:
		shoot()

func shoot() -> void:
	if !can_shoot || waiting_for_burst:
		return
	bullet_count += 1
	var bullet : Bullet = bullet_preset.duplicate()
	bullet.global_position = bullet_spawn_point
	bullet.speed = bullet_speed
	bullet.target_node = NodeLinker.player
	bullet.rotation = rotation - randf_range(90 - range_angle, 90 + range_angle)
	bullet.velocity = -global_transform.y * 2
	call_deferred("set_bullet_color",bullet_color,bullet)
	get_parent().add_child(bullet)
	can_shoot = false
	if bullet_count >= bullet_per_burst:
		timer_burst.start(time_between_burst)
	else:
		timer_bullet.start(time_between_bullets)

func _on_timer_bullet_timeout() -> void:
	can_shoot = true

func _on_timer_burst_timeout():
	bullet_count = 0
	can_shoot = true


func _on_anim_player_animation_finished(anim_name : StringName) -> void:
	if anim_name == "death":
		queue_free()
