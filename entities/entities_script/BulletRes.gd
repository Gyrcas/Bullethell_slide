extends Resource
class_name BulletRes

@export var ignore_sender : bool = true
@export var speed : float = 2.5
@export var max_speed : float = 15
@export var turn_speed : float = 10
@export var target_position : Vector2 = Vector2(0,0)
@export var target_node : Node2D
@export var damage : float = 1
@export var precision : float = 0.05
