@tool
extends Area2D
class_name Laser

@onready var line : Line2D = $line
@onready var col : CollisionShape2D = $col

@export var damage : float = 1

@export var dimensions : Vector2 = Vector2(100,500) : set = set_dimensions

@export var dim_col_scale : Vector2 = Vector2(0.3,0.9) : set = set_dim_col_scale

@export var expel_force : float = 100

func set_dim_col_scale(value : Vector2) -> void:
	dim_col_scale = value
	set_dimensions(dimensions)

@export var open_speed : float = 1.5

var is_open : bool = true

var target : Vector2 : set = set_target

func set_target(value : Vector2) -> void:
	target = value
	if !is_node_ready():
		await ready
	if !line.is_node_ready():
		await line.ready
	line.points[1] = value

func set_dimensions(value : Vector2) -> void:
	dimensions = value
	target = Vector2(0,dimensions.y)
	if !is_node_ready():
		await ready
	if !line.is_node_ready():
		await line.ready
	if !col.is_node_ready():
		await col.ready
	line.width = dimensions.x
	line.points[1] = Vector2(0,dimensions.y)
	col.shape.size = dimensions * dim_col_scale
	col.position.y = dimensions.y / 2 * dim_col_scale.y

func _ready() -> void:
	connect("body_entered",_on_body_entered)

func close(skip_anim : bool = false) -> void:
	is_open = false
	var tween : Tween = create_tween()
	var speed : float = 0.0 if skip_anim else open_speed
	tween.parallel().tween_property(self,"target",Vector2.ZERO,speed)
	tween.parallel().tween_property(col.shape,"size",Vector2(col.shape.size.x,0),speed)
	tween.parallel().tween_property(col,"position",Vector2.ZERO,speed)
	tween.tween_callback(func():
		col.disabled = true
	)

func open(skip_anim : bool = false) -> void:
	is_open = true
	col.set_deferred("disabled",false)
	var speed : float = 0.0 if skip_anim else open_speed
	var tween : Tween = create_tween()
	tween.parallel().tween_property(self,"target",Vector2(0,dimensions.y),speed)
	tween.parallel().tween_property(col.shape,"size",dimensions * dim_col_scale,speed)
	tween.parallel().tween_property(col,"position",Vector2(0,dimensions.y / 2 * dim_col_scale.y),speed)

func _on_body_entered(body : Node2D) -> void:
	if body is MoverEntity:
		body.velocity = -body.velocity.normalized() * expel_force
		body.health -= damage
