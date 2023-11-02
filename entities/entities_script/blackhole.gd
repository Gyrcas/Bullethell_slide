extends Area2D

@export var strength : float = 30

func _physics_process(delta : float) -> void:
	for victim in get_overlapping_bodies():
		if victim is CharacterBody2D:
			victim.velocity += victim.global_position.direction_to(global_position) * strength * delta
