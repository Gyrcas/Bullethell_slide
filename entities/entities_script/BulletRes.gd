extends Resource
class_name BulletRes

@export var ignore_sender : bool = true
@export var max_speed : float = 15
@export var move_speed : float = 2.5
@export var turn_speed : float = 10
@export var target_node : Node2D
@export var damage : float = 1
@export var maniability : float = 0.25
@export var nano : int = 10
@export var global_position : Vector2 = Vector2.ZERO
@export var rotation : float = 0
@export var sender : Node2D
@export var velocity : Vector2 = Vector2.ZERO
@export var color : Color = Color(1,1,1)
@export_enum("bullet","bomb") var type : String = "bullet"

var bullet_scene : PackedScene = await NodeLinker.request_resource("bullet.tscn")

func instantiate() -> Bullet:
	var bullet : Bullet = bullet_scene.instantiate()
	match type:
		"bullet":
			bullet.set_script(Bullet)
		"bomb":
			bullet.set_script(Bomb)
		_:
			bullet.set_script(Bullet)
	bullet.max_speed = max_speed
	bullet.turn_speed = turn_speed
	bullet.move_speed = move_speed
	bullet.target_node = target_node
	bullet.damage = damage
	bullet.maniability = maniability
	bullet.nano = nano
	bullet.set_sender(sender)
	bullet.global_position = global_position
	bullet.rotation = rotation
	bullet.velocity = velocity
	bullet.color = color
	return bullet
