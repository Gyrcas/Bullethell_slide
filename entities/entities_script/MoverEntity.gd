extends SpaceMover
class_name MoverEntity

@onready var shoot_timer : Timer = $shoot_timer

signal died

var health : float = 100 : set = set_health
@export var health_max : float = 100

func set_health(value : float) -> void:
	health = value

@export var nano_max : int = 100
var nano : int = nano_max : set = set_nano

func set_nano(value : int) -> void:
	nano = value

var can_shoot : bool = true
@export var shoot_cooldown : float = 0.1

@export var bullet_preset : BulletRes = BulletRes.new()

func _ready() -> void:
	if !shoot_timer:
		shoot_timer = Timer.new()
		add_child(shoot_timer)
	if !shoot_timer.is_connected("timeout",_on_shoot_timer_timeout):
		shoot_timer.connect("timeout",_on_shoot_timer_timeout)
	bullet_preset.sender = self

func shoot(can : bool = can_shoot && nano >= bullet_preset.nano) -> void:
	if can:
		can_shoot = false
		shoot_timer.start(shoot_cooldown)
		var bullet : Bullet = bullet_preset.instantiate()
		bullet.rotation = rotation
		bullet.global_position = global_position + global_transform.x * 40
		bullet.velocity = velocity
		bullet.sender = bullet_preset.sender
		get_parent().add_child.call_deferred(bullet)

# Allow shooting once shoot_cooldown is finished
func _on_shoot_timer_timeout() -> void:
	can_shoot = true
