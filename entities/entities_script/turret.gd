extends MoverEntity
class_name Turret

@export var time_between_burst : float = 2.5
@export var bullet_per_burst : int = 5
@export var range_angle : float = 20
@export var max_distance : float = 5000

@onready var timer_burst : Timer = $timer_burst
@onready var bullet_spawn_point : Vector2 = $bullet_spawn_point.global_position
@onready var detection : RayCast2D = $detection

var bullet_color : Color = Color(5,0,0)

var bullet_count : int = 0

var waiting_for_burst : bool = false

func set_bullet_color(value : Color = bullet_color, bullet : Bullet = Bullet.new()) -> void:
	bullet.sprite.color = value

func _ready() -> void:
	detection.add_exception(self)
	detection.rotation = -rotation
	bullet_preset.rotation = rotation - randf_range(90 - range_angle, 90 + range_angle)
	bullet_preset.global_position = bullet_spawn_point
	bullet_preset.velocity = -global_transform.y * 2
	bullet_preset.target_node = NodeLinker.player
	set_collision_layer_value(NodeLinker.auto_target_collision_level,true)

func _physics_process(_delta : float) -> void:
	if !NodeLinker.player:
		return
	detection.target_position = NodeLinker.player.global_position - detection.global_position
	var bullet : Bullet = shoot(
		detection.get_collider() == NodeLinker.player && nano >= bullet_preset.nano && can_shoot && !waiting_for_burst
	)
	if bullet:
		bullet.global_position = bullet_preset.global_position
		bullet_count += 1
		if bullet_count >= bullet_per_burst:
			shoot_timer.stop()
			timer_burst.start(time_between_burst)

func _on_timer_burst_timeout():
	bullet_count = 0
	can_shoot = true
