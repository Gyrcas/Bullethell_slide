extends CharacterBody2D
class_name SpaceMover

# movement var
@export var max_speed : float = 15
@export var move_speed : float = 10
@export var turn_speed : float = 5
@export var friction : float = 3
@export var gravity : Vector2 = Vector2(0,0)
@export var maniability : float = 0.25

func movement(move : int, delta : float, speed : float) -> void:
	velocity += global_transform.x * move * delta * move_speed
	velocity = velocity.lerp(global_transform.x * (move if move else (1 if velocity.angle_to(global_transform.x) < 1.5 else -1)) * speed,0.1 * maniability)

func turning(turn, delta) -> void:
	rotate(turn * delta * turn_speed)

func do_move(move : int, turn : int, delta : float, speed : float) -> Variant:
	if turn:
		turning(turn, delta)
	if move:
		movement(move, delta, speed)
	else:
		velocity = velocity.move_toward(Vector2.ZERO,friction * delta)
	
	if speed > max_speed:
		velocity = velocity.normalized() * max_speed
	
	# Add gravity
	velocity += gravity * delta
	
	return move_and_collide(velocity * Engine.time_scale)
