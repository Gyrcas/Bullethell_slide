extends MoverEntity
class_name Extractor

@export var move_range : Vector2 = Vector2(1000,1000)
@onready var range_start : Vector2 = global_position - move_range / 2
@onready var range_end : Vector2 = global_position + move_range / 2
@onready var hole_timer : Timer = $hole_timer
@export var move_cooldown : float = 5
@export var hole_cooldown : float = 10
var can_hole : bool = true
@onready var move_timer : Timer = $move_timer
var destination : Vector2 = Vector2.ZERO
var hole_scene : PackedScene = NodeLinker.request_resource("blackhole.tscn")

func _ready() -> void:
	check_dependance()
	_on_move_timer_timeout()
	bullet_preset.target_node = NodeLinker.player
	set_collision_layer_value(NodeLinker.auto_target_collision_level,true)

@onready var detection : RayCast2D = $detection

func _physics_process(delta : float) -> void:
	if dying:
		return
	velocity += global_position.direction_to(destination) * move_speed * delta
	if velocity.x / velocity.normalized().x > max_speed:
		velocity = velocity.normalized() * max_speed
	var collision = move_and_collide(velocity)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
	detection.target_position = detection.global_position.direction_to(NodeLinker.player.global_position) * (detection.global_position.distance_to(NodeLinker.player.global_position) + 100)
	var bullet : Bullet = shoot(
		detection.get_collider() == NodeLinker.player && nano >= bullet_preset.nano && can_shoot
	)
	if bullet:
		bullet.velocity = Vector2.ZERO
	if can_hole && detection.get_collider() == NodeLinker.player:
		var hole : Area2D = hole_scene.instantiate()
		can_hole = false
		get_parent().add_child(hole)
		hole.global_position = NodeLinker.player.global_position
		hole_timer.start(hole_cooldown)

func _on_move_timer_timeout() -> void:
	destination = Vector2(randf_range(range_start.x,range_end.x),randf_range(range_start.y,range_end.y))
	move_timer.start(move_cooldown)


func _on_hole_timer_timeout() -> void:
	can_hole = true
