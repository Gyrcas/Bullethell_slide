extends Node2D
class_name DeathParticles

@onready var sparkle : GPUParticles2D = $sparkle
@onready var blast : CPUParticles2D = $blast
@onready var lifetime_timer : Timer = $lifetime_timer

var lifetime : float = 1

func delete_self() -> void:
	queue_free()

func _init() -> void:
	Global.connect("scene_changed",delete_self)

func _ready() -> void:
	sparkle.lifetime = lifetime
	blast.lifetime = lifetime / 3
	blast.scale_amount_min = lifetime * 2
	sparkle.emitting = true
	blast.emitting = true
	lifetime_timer.start(lifetime)
	await lifetime_timer.timeout
	queue_free()
