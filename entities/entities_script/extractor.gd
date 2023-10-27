extends MoverEntity
class_name Extractor

@export var move_range : Vector2 = Vector2(1000,1000)
@onready var range_start : Vector2 = global_position - move_range / 2
@onready var range_end : Vector2 = global_position + move_range / 2
@export var move_cooldown : float = 5
@onready var move_timer : Timer = $move_timer
var destination : Vector2 = Vector2.ZERO

func _ready() -> void:
	_on_move_timer_timeout()


func _physics_process(_delta) -> void:
	shoot()


func _on_move_timer_timeout() -> void:
	destination = Vector2(randi_range(range_start.x,range_end.x),randi_range(range_start.y,range_end.y))
	move_timer.start(move_cooldown)
