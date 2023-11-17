extends Area2D
class_name Laser

@onready var line : Line2D = $line
@onready var col : CollisionShape2D = $col

@export var damage : float = 5

@export var dimensions : Vector2 = Vector2(100,500) : set = set_dimensions

func set_dimensions(value : Vector2) -> void:
	dimensions = value
	(func():
		line.width = dimensions.x
		line.points[1] = Vector2(0,dimensions.y)
		col.shape.size = dimensions
		col.position.y = dimensions.y / 2
	).call_deferred()

func close() -> void:
	pass

func open() -> void:
	pass


func _on_body_entered(body : Node2D) -> void:
	if body is Player:
		pass


func _on_body_exited(body : Node2D) -> void:
	if body is Player:
		pass
