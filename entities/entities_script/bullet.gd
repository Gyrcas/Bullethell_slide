extends SpaceMover
class_name Bullet
## Simple bullet. Use tscn file

@onready var sprite : Node2D = $sprite

# COllision to avoid bullets sticking too close together
@onready var avoid : Area2D = $avoid

var color : Color = Color(1,1,1)

var death_particles_scene : PackedScene = await NodeLinker.request_resource("death_particles.tscn")

# How much nano the bullet cost
var nano : int = 10

# Who created the bullet
var sender : Node2D : set = set_sender

# Set wether the bullet can it the one who sent it
var ignore_sender : bool = true : set = set_ignore_sender
func set_ignore_sender(value : bool) -> void:
	ignore_sender = value
	if sender:
		if ignore_sender:
			add_collision_exception_with(sender)
		else:
			remove_collision_exception_with(sender)

# Set sender and update connections to manage bullets
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

# The node to target. Without target, just go forward
var target_node : Node2D

var damage : float = 1

# How much avoid is reduced
var avoid_div : float = 100

# All the types of damage. Some characters have resistance, weakness or immunities to attacks
var damage_types : PackedStringArray = ["normal"]

func die() -> void:
	# Add nano back to the sender
	if sender != null:
		sender.nano += nano
	
	var particles : DeathParticles = death_particles_scene.instantiate()
	particles.global_position = global_position
	particles.lifetime = 0.5
	
	var sound_id : String = AudioPlayer.play("sounds/bullet.wav",false)
	AudioPlayer.set_bus_by_name(sound_id,"VFX")
	AudioPlayer.set_position(sound_id,global_position)
	AudioPlayer.set_pitch(sound_id,randf_range(0.5,1.5))
	AudioPlayer.set_volume(sound_id,-10)
	
	#Added if because would sometime crash because sprite was null
	if sprite:
		particles.modulate = sprite.color
	if get_parent():
		get_parent().add_child(particles)
	queue_free()

func collide(collision) -> void:
	var collider : Node2D = collision.get_collider()
	
	if collider.get("sender") == sender:
		add_collision_exception_with(collider)
		return
	
	if collider is MoverEntity:
		collider.apply_damage(damage,damage_types)
	
	if collider is CharacterBody2D:
		collider.velocity += velocity
	
	die()

func _ready() -> void:
	sprite.color = color

func _physics_process(delta : float) -> void:
	# Make sure that target node is set to null if not valid
	if !target_node:
		target_node = null
	
	# Get the target node position if has target node or just go forward if not
	var target_position : Vector2 = (
		target_node.global_position if target_node 
		else global_position + global_transform.x * 100
	)
	
	var angle_target : float = get_angle_to(target_position)
	
	var turn : float = angle_target / abs(angle_target)
	
	# Avoid other bullets
	for body in avoid.get_overlapping_bodies():
		if body is Bullet && body != self:
			angle_target = get_angle_to(body.global_position)
			turn += -(angle_target / abs(angle_target)) / avoid_div
	# Prevent from turning too much
	clampf(turn,-1,1)
	
	var collision : Variant = do_move(1, int(turn), delta, 
		velocity.x / velocity.normalized().x if velocity.x != 0 else 1.0
	)
	
	if collision:
		collide(collision)

func on_change_target() -> void:
	target_node = sender.target.current_target
