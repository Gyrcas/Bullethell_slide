extends Resource
class_name BulletRes

@export var ignore_sender : bool = true
@export var max_speed : float = 15
@export var move_speed : float = 2.5
@export var turn_speed : float = 10
@export var target_position : Vector2 = Vector2(0,0)
@export var target_node : Node2D
@export var damage : float = 1
@export var maniability : float = 0.25
@export var nano : int = 10
@export var global_position : Vector2 = Vector2.ZERO
@export var rotation : float = 0
@export var sender : Node2D
@export var velocity : Vector2 = Vector2.ZERO
@export_enum("default","bomb") var type : String = "default"

var bullet_scene : PackedScene

func _init() -> void:
	(func():
		bullet_scene = NodeLinker.request_resource("bullet.tscn")
	).call_deferred()

func instantiate() -> Bullet:
	var bullet : Bullet = bullet_scene.instantiate()
	var script : String = "bullet.gd"
	match type:
		"bomb":
			script = "bomb.gd"
	bullet.set_script(NodeLinker.request_resource(script))
	bullet.max_speed = max_speed
	bullet.turn_speed = turn_speed
	bullet.target_position = target_position
	bullet.move_speed = move_speed
	bullet.target_node = target_node
	bullet.damage = damage
	bullet.maniability = maniability
	bullet.nano = nano
	bullet.set_sender(sender)
	bullet.global_position = global_position
	print(global_position, " ",bullet.global_position)
	bullet.rotation = rotation
	bullet.velocity = velocity
	return bullet
