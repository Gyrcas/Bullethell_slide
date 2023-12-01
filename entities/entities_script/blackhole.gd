extends Area2D
class_name blackhole
## Create a blackhole. Use tscn file

## Force of the pull toward center
@export var strength : float = 42

## Time in seconds it will stay active. If lower than or equal to zero, is infinite
@export var lifetime : float = 10

## Time before the blackhole spawn. Will display a shadow as a warning
@export var time_before_spawn : float = 1


@onready var anim : AnimationPlayer = $anim
@onready var col : CollisionShape2D = $col
@onready var timer : Timer = $timer
@onready var shader : Sprite2D = $visuals/visual/shader

func _ready() -> void:
	# Shadow, not active yet
	anim.play("warning")
	timer.start(time_before_spawn)
	await timer.timeout
	# spawn and activate the blackhole
	col.disabled = false
	anim.play("spawn")
	if lifetime > 0:
		timer.start(lifetime)
		await timer.timeout
		anim.play("despawn")
	

# Replace TIME in shader
var shader_time : float = 0

func _physics_process(delta : float) -> void:
	shader_time += delta
	shader.material.set_shader_parameter("shader_time",shader_time)
	
	#Attract bodies inside
	for victim in get_overlapping_bodies():
		if victim is CharacterBody2D:
			victim.velocity += victim.global_position.direction_to(global_position) * strength * delta


func _on_anim_animation_finished(anim_name : String) -> void:
	if anim_name == "despawn":
		queue_free()
