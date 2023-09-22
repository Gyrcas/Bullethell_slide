extends CharacterBody2D
class_name Player

# Nodes
@onready var shoot_timer : Timer = $shoot_timer
@onready var ray_boost : RayCast2D = $ray_boost
@onready var body : Polygon2D = $body
@onready var stun_timer : Timer = $stun_timer
@onready var target : Node2D = $target

var death_particles_scene : PackedScene = preload(NodeLinker.death_particles)

var bullet_color : Color = Color(1,1,1)

var health : float = 100 : set = set_health
var health_max : float = 100

func set_health(value : float) -> void:
	health = value

# movement var
var move_speed : float = 10
var turn_speed : float = 5
var friction : float = 3
var gravity : Vector2 = Vector2(0,0)
var maniability : float = 0.25

# shoot var
var can_shoot : bool = true
var shoot_cooldown : float = 0.1

# trail var
@onready var trail : Line2D = $trail
var trail_length : int = 50
const trail_gradiant_presets_path : String = "res://trail_gradient_presets/"
var trail_gradiant_presets : Dictionary = {
	"base":preload(trail_gradiant_presets_path + "base.tres"),
	"boost":preload(trail_gradiant_presets_path + "boost.tres")
}
const trail_update_time : float = 0.05
@onready var trail_timer : Timer = $trail_timer

@export var outline : Color = Color(0,0,0)
@export var outline_width : float = 3

func _draw() -> void:
	for i in range(1 , body.polygon.size()):
		draw_line(body.polygon[i-1] , body.polygon[i], outline , outline_width)
	draw_line(body.polygon[body.polygon.size() - 1] , body.polygon[0], outline , outline_width)

# boost var
var boost_speed_mult : float = 3
const boost_angle : float = 90
const boost_lerp : float = 0.4

# collision var
const min_speed_reduct : float = 3
const col_speed_reduct : float = 0.5
const max_speed_bouce : float = 4

var is_stunned : bool = false

var bullet_preset : Bullet = preload(NodeLinker.bullet_scene).instantiate()
var bullets : Array[CharacterBody2D] = []

func _ready() -> void:
	# Create trail
	remove_child(trail)
	get_parent().add_child.call_deferred(trail)
	trail.gradient = trail_gradiant_presets["base"]
	trail.points = []
	for i in trail_length:
		trail.add_point(global_position,i)
	
	
	NodeLinker.player = self
	trail_timer.start(trail_update_time)
	
	target.connect("target_lost",on_target_lost)

# Get current speed with velocity
func get_speed() -> float:
	var speed : float = velocity.x / velocity.normalized().x
	return 0.0 if is_nan(speed) else speed

func set_speed(speed : float) -> void:
	velocity = velocity.normalized() * speed

var max_speed : float = 15

func set_bullet_color( value : Color = bullet_color, bullet : Bullet = Bullet.new()) -> void:
	bullet.sprite.color = value

func _physics_process(delta : float) -> void:
	# Get movement inputs
	var move : int = int(Input.get_axis("down","up"))
	var turn : int = int(Input.get_axis("left","right"))
	
	# Apply movement inputs
	if turn:
		rotate(turn * delta * turn_speed)
	if move:
		var move_velocity : Vector2 = global_transform.x * move * delta * move_speed
		if ray_boost.is_colliding():
			move_velocity *= boost_speed_mult
		velocity += move_velocity
		var velo_angle : float = velocity.angle_to(global_transform.x)
		velocity = velocity.lerp(global_transform.x * (move if move else (1 if velo_angle < 1.5 else -1)) * get_speed(),0.1 * maniability)
	else:
		velocity = velocity.move_toward(Vector2.ZERO,friction * delta)
	
	if get_speed() > max_speed:
		set_speed(max_speed)
	
	# Add gravity
	velocity += gravity * delta
	
	#if get_speed() > 10:
	#	set_speed(10)
	
	# Execute velocity and get collision
	var collision = move_and_collide(velocity * Engine.time_scale)
	
	# If collision, manage collision
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		velocity += collision.get_normal() * 3
		if get_speed() >= min_speed_reduct:
			velocity *= col_speed_reduct
		if get_speed() > max_speed_bouce:
			velocity = velocity.normalized() * max_speed_bouce
	
	if ray_boost.is_colliding():
		var col_normal : Vector2 = ray_boost.get_collision_normal()
		var velo_angle : float = abs(velocity.angle_to(col_normal))
		if ray_boost.global_position.distance_to(ray_boost.get_collision_point()) < 10:
			global_position = global_position.lerp(global_position + col_normal * 10,0.2)
		else:
			global_position = global_position.lerp(global_position + col_normal * 10,0.01)
		if velo_angle > deg_to_rad(boost_angle):
			velocity = velocity.lerp(velocity.slide(col_normal),boost_lerp)
		
		
	# Shoot code
	if Input.is_action_pressed("left_click") && can_shoot:
		can_shoot = false
		shoot_timer.start(shoot_cooldown)
		var bullet : Bullet = bullet_preset.duplicate()
		bullet.rotation = rotation
		bullet.global_position = global_position + global_transform.x * 40
		bullet.velocity = velocity
		bullet.sender = self
		bullet.speed = 10.5
		bullet.target_node = target
		bullet.precision = 0.5
		call_deferred("set_bullet_color",bullet_color,bullet)
		get_parent().add_child(bullet)
		bullets.append(bullet)
	
	trail.points[trail.points.size() - 1] = global_position
	#auto_target.look_at(get_global_mouse_position())
	

# Allow shooting once shoot_cooldown is finished
func _on_shoot_timer_timeout() -> void:
	can_shoot = true


func _on_stun_timer_timeout() -> void:
	pass # Replace with function body.


#AUto Target----------------------------------------------
var target_zone_width : float = 300
@onready var auto_target : Area2D = $auto_target
var current_target_id : int = -1
var auto_targets : Array[Node2D] = []

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("auto_target"):
		current_target_id += 1
		do_target()
		
func do_target() -> void:
	if auto_targets.size() == 0:
		return
	if current_target_id >= auto_targets.size():
		current_target_id = 0
	target.change_target(auto_targets[current_target_id])

func on_target_lost() -> void:
	do_target()

func _on_auto_target_body_entered(_body : Node2D) -> void:
	if _body.is_in_group("targetable"):
		auto_targets.append(_body)


func _on_auto_target_body_exited(_body : Node2D) -> void:
	auto_targets.erase(_body)



func _on_trail_timer_timeout() -> void:
	trail.remove_point(0)
	trail.add_point(global_position,trail_length)
	trail_timer.start(trail_update_time)
