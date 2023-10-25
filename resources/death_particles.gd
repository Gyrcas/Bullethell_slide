extends Node2D
class_name DeathParticles

@onready var sparkle : GPUParticles2D = $sparkle
@onready var blast : GPUParticles2D = $sparkle/blast

var lifetime : float = 1

func _ready() -> void:
	sparkle.lifetime = lifetime
	blast.lifetime = lifetime
	sparkle.emitting = true
	blast.emitting = true

func _process(_delta : float) -> void:
	if !sparkle.emitting && !blast.emitting:
		queue_free()
