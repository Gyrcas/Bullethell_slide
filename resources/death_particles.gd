extends Node2D
class_name DeathParticles

@onready var sparkle : GPUParticles2D = $sparkle
@onready var blast : CPUParticles2D = $blast

var lifetime : float = 1

func _ready() -> void:
	sparkle.lifetime = lifetime
	blast.lifetime = lifetime / 3
	blast.scale_amount_min = lifetime * 2
	sparkle.emitting = true
	blast.emitting = true
	await get_tree().create_timer(lifetime * 5).timeout
	queue_free()
