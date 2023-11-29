extends SpaceMover
class_name MoverEntity

@onready var shoot_timer : Timer = $shoot_timer

signal died

@export var health_max : float = 5
var health : float = health_max : set = set_health

var death_particles_scene : PackedScene = await NodeLinker.request_resource("death_particles.tscn")

@onready var anim : AnimationPlayer = $anim

var dying : bool = false

@export var imunities : Array[String] = []
@export var vulnerabilities : Array[String] = []
@export var restistances : Array[String] = []

func apply_damage(damage : float, types:PackedStringArray = ["normal"]) -> void:
	var not_hurt : bool = true
	for type in types:
		if !imunities.has(type):
			not_hurt = false
			break
	if not_hurt:
		return
	set_health(health - damage)

func die() -> void:
	dying = true
	can_shoot = false
	shoot_timer.stop()
	var particles : DeathParticles = death_particles_scene.instantiate()
	particles.global_position = global_position
	particles.lifetime = 3
	get_parent().add_child(particles)
	var sound_id : String = AudioPlayer.play("sounds/Misc_DissolveSweep.wav",false)
	AudioPlayer.set_position(sound_id, global_position)
	AudioPlayer.set_bus_by_name(sound_id,"VFX")
	anim.play("death")
	died.emit()

func set_health(value : float) -> void:
	health = value
	if health <= 0 && !dying:
		die()

@export var nano_max : float = 100
var nano : float = nano_max : set = set_nano

func set_nano(value : float) -> void:
	nano = value

var can_shoot : bool = true
@export var shoot_cooldown : float = 0.1

@export var bullet_preset : BulletRes = BulletRes.new()

func check_dependance() -> void:
	if !shoot_timer:
		shoot_timer = Timer.new()
		add_child(shoot_timer)
		push_warning("Timer shoot_timer not set")
	if !shoot_timer.is_connected("timeout",_on_shoot_timer_timeout):
		shoot_timer.connect("timeout",_on_shoot_timer_timeout)
		push_warning("Shoot_timer timeout not connected to _on_shoot_timer_timeout")
	if !anim:
		anim = AnimationPlayer.new()
		add_child(anim)
		push_warning("AnimationPlayer anim not set")
	if !anim.has_animation("death"):
		var library : AnimationLibrary = AnimationLibrary.new()
		library.add_animation("death",await NodeLinker.request_resource("death_animation.res"))
		anim.add_animation_library("library",library)
		push_warning("animation player doesn't have the animation death")
	if !anim.is_connected("animation_finished",_on_anim_animation_finished):
		anim.connect("animation_finished",_on_anim_animation_finished)
		push_warning("anim animation_finished not connected to _on_anim_animation_finished")

func _ready() -> void:
	check_dependance()
	bullet_preset.sender = self

func shoot(can : bool = can_shoot && nano >= bullet_preset.nano) -> Bullet:
	if can:
		can_shoot = false
		shoot_timer.start(shoot_cooldown)
		var bullet : Bullet = bullet_preset.instantiate()
		bullet.rotation = rotation
		bullet.global_position = global_position + global_transform.x * 40
		bullet.velocity = velocity
		bullet.sender = self
		get_parent().add_child.call_deferred(bullet)
		return bullet
	return null

# Allow shooting once shoot_cooldown is finished
func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func _on_anim_animation_finished(anim_name : String) -> void:
	if anim_name == "death":
		queue_free()
