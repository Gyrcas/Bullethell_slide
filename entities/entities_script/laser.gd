@tool
extends Area2D
class_name Laser

@onready var line : Line2D = $line
@onready var col : CollisionShape2D = $col

@export var damage : float = 1

@export var dimensions : Vector2 = Vector2(100,500) : set = set_dimensions

@export var dim_col_scale : Vector2 = Vector2(1,1) : set = set_dim_col_scale

@export var expel_force : float = 100

func set_dim_col_scale(value : Vector2) -> void:
	dim_col_scale = value
	set_dimensions(dimensions)

@export var open_speed : float = 1.5

var target : Vector2 : set = set_target

func set_target(value : Vector2) -> void:
	target = value
	if line:
		line.points[1] = value
	else:
		set_target.call_deferred(target)

func set_dimensions(value : Vector2) -> void:
	dimensions = value
	target = Vector2(0,dimensions.y)
	if line && col:
		line.width = dimensions.x
		line.points[1] = Vector2(0,dimensions.y)
		col.shape.size = dimensions * dim_col_scale
		col.position.y = dimensions.y / 2 * dim_col_scale.y
	else:
		set_dimensions.call_deferred(value)

func close(skip_anim : bool = false) -> void:
	var tween : Tween = create_tween()
	var speed : float = 0.0 if skip_anim else open_speed
	tween.parallel().tween_property(self,"target",Vector2.ZERO,speed)
	tween.parallel().tween_property(col.shape,"size",Vector2(col.shape.size.x,0),speed)
	tween.parallel().tween_property(col,"position",Vector2.ZERO,speed)
	tween.tween_callback(func():
		col.disabled = true
	)
	tween.play()

func open(skip_anim : bool = false) -> void:
	col.set_deferred("disabled",false)
	var speed : float = 0.0 if skip_anim else open_speed
	var tween : Tween = create_tween()
	tween.parallel().tween_property(self,"target",Vector2(0,dimensions.y),speed)
	tween.parallel().tween_property(col.shape,"size",dimensions * dim_col_scale,speed)
	tween.parallel().tween_property(col,"position",Vector2(0,dimensions.y / 2 * dim_col_scale.y),speed)
	tween.play()

func _on_body_entered(body : Node2D) -> void:
	if body is MoverEntity:
		body.velocity = -body.velocity.normalized() * expel_force
		body.health -= damage
