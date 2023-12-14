extends MoverEntity
class_name Player

# Nodes
@onready var body : Polygon2D = $body
@onready var target : Node2D = $target
@onready var camera : Camera2D = $camera
@onready var health_bar : TextureProgressBar = $camera/ui/hud/health
@onready var nano_bar : TextureProgressBar = $camera/ui/hud/nanos
@onready var interaction_lbl : Label = $camera/ui/interaction
@onready var pause_menu : PauseMenu = $camera/ui/pause_layer/pause_menu
@onready var bullet_type_lbl : Label = $camera/ui/hud/bullet_type
@onready var perks_wheel : PerksWheel = $camera/ui/perks
@onready var col : CollisionShape2D = $col
@onready var dialogue : CanvasLayer = $camera/ui/hud/dialogue
@onready var hit_slow_mo_area : Area2D = $hit_slow_mo_area

var interaction : Node = null : set = set_interaction
var controllable : bool = true

func set_interaction(value : Node) -> void:
	interaction = value
	interaction_lbl.visible = !!interaction
	if interaction:
		var events : Array[InputEvent] = InputMap.action_get_events("interact")
		interaction_lbl.text = "Press " + (events[0].as_text() if events.size() > 0 else "nothing (no key set)") + " to interact"

# trail var
@onready var trail : Line2D = $trail
var trail_length : int = 50
const trail_update_time : float = 0.05
@onready var trail_timer : Timer = $trail_timer

# collision var
const max_speed_bouce : float = 10

func set_health(value : float) -> void:
	if value < health:
		Global.shake_camera(camera,Vector2(100,100),25,0.01)
	health = value
	var tween : Tween = create_tween()
	tween.tween_property(
		health_bar,"value",health / health_max * health_bar.max_value,0.1
	)
	if health <= 0 && !dying:
		controllable = false
		die()

func set_nano(value : float) -> void:
	nano = value
	var tween : Tween = create_tween()
	tween.tween_property(
		nano_bar,"value",float(nano) / nano_max * nano_bar.max_value,0.1)

func _ready() -> void:
	check_dependance()
	anim.play("start")
	trail.reparent.call_deferred(get_parent())
	trail.set_deferred("rotation",0)
	trail.set_deferred("global_position",Vector2.ZERO)
	if GS.save_loaded:
		GS.save_loaded = false
		if str_to_var(GS.data.position):
			global_position = str_to_var(GS.data.position)
	# Create trail
	trail.points = []
	for i in trail_length:
		trail.add_point(global_position,i)
	
	Global.player = self
	trail_timer.start(trail_update_time)
	
	target.connect("target_lost",on_target_lost)
	
	auto_target.set_collision_mask_value(Global.auto_target_collision_level,true)
	
	bullet_preset.sender = self
	bullet_preset.target_node = target

var joy_stick_dead_zone : float = 0.2

func directional_turn() -> int:
	var target_vector : Vector2 = Vector2(
		Input.get_joy_axis(0,JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0,JOY_AXIS_LEFT_Y)
	)
	if abs(target_vector.x) < joy_stick_dead_zone:
		target_vector.x = 0
	if abs(target_vector.y) < joy_stick_dead_zone:
		target_vector.y = 0
	var angle_target : float = get_angle_to(global_position + target_vector)
	return (angle_target / abs(angle_target)) if angle_target else 0

func _physics_process(delta : float) -> void:
	# Get movement inputs
	var move : int = 0
	var turn : int = 0
	
	if !dying && controllable:
		if Input.is_joy_known(0):
			if Global.use_directional_turn:
				turn = directional_turn()
			else:
				turn = int(Input.get_axis("left","right"))
				if turn == 0:
					if Input.get_joy_axis(0,JOY_AXIS_LEFT_X) > 0 + joy_stick_dead_zone:
						turn = 1
					elif Input.get_joy_axis(0,JOY_AXIS_LEFT_X) < 0 - joy_stick_dead_zone:
						turn = -1
			if Input.is_action_pressed("controller_forward"):
				move = 1
			elif Input.is_action_pressed("controller_backward"):
				move = -1
		else:
			move = int(Input.get_axis("down","up"))
			turn = int(Input.get_axis("left","right"))
	
	var speed : float = velocity.x / velocity.normalized().x
	if is_nan(speed):
		speed = 0.0
	
	# Execute velocity and get collision
	var collision : Variant = do_move(move,turn,delta, speed)
	# If collision, manage collision
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		velocity += collision.get_normal()
		if speed > max_speed_bouce:
			velocity = velocity.normalized() * max_speed_bouce
		
	shoot(
		Input.is_action_pressed("left_click") && can_shoot && nano >= bullet_preset.nano && !perks_wheel.visible && controllable
	)
	
	ultra_mode(delta, move)
	
	trail.points[trail.points.size() - 1] = global_position
	
	auto_target.global_position = camera.get_screen_center_position()
#Auto Target----------------------------------------------
var target_zone_width : float = 300
@onready var auto_target : Area2D = $auto_target
var current_target_id : int = -1

var old_maniab : float = maniability
var old_move_speed : float = move_speed
var old_turn_speed : float = turn_speed
var old_max_speed : float = max_speed
var ultra_mode_max_speed : float = 5
var ultra_mode_move_speed : float = 25
var ultra_mode_turn_speed : float = 5
var ultra_mode_maniab : float = 1
var ultra_mode_cost : float = 100
var ultra_mode_recharge_div : float = 2
var ultra_mode_usage : float = 0
var ultra_mode_cooldown : float = 1
var ultra_mode_no_move_cost_div : float = 2
var ultra_mode_on : bool = false

@onready var ultra_mode_timer : Timer = $ultra_mode/timer
@onready var ultra_mode_particles : CPUParticles2D = $ultra_mode/particles
@onready var ultra_mode_modulate : CanvasModulate = $ultra_mode/modulate
@onready var ultra_mode_light : PointLight2D = $ultra_mode/light

var ultra_mode_tween : Tween

func ultra_mode(delta : float, move : int) -> void:
	if Input.is_action_pressed("ultra_mode") && controllable && can_ultra_mode:
		if nano < ultra_mode_cost * delta:
			can_ultra_mode = false
			ultra_mode_timer.start(ultra_mode_cooldown)
		if !ultra_mode_on:
			ultra_mode_on = true
			ultra_mode_particles.emitting = true
			if ultra_mode_tween && ultra_mode_tween.is_valid():
				ultra_mode_tween.kill()
			ultra_mode_tween = create_tween()
			#ultra_mode_tween.parallel().tween_property(ultra_mode_light,"energy",1,0.2)
			ultra_mode_tween.parallel().tween_property(ultra_mode_modulate,"color",Color("006cff"),0.2)
			maniability = old_maniab + ultra_mode_maniab
			move_speed = old_move_speed + ultra_mode_move_speed
			turn_speed = old_turn_speed + ultra_mode_turn_speed
			max_speed = old_max_speed + ultra_mode_max_speed
		ultra_mode_light.energy = move_toward(ultra_mode_light.energy,nano / nano_max,0.1)
		var m_cost : float = ultra_mode_cost * delta
		if move:
			Global.set_time_scale(0.4,true,2)
		else:
			Global.set_time_scale(0.3,true,2)
			m_cost /= ultra_mode_no_move_cost_div
		nano -= m_cost
		ultra_mode_usage += m_cost
	elif ultra_mode_usage > 0:
		Global.set_time_scale(1,true,2)
		ultra_mode_usage -= ultra_mode_cost * delta / ultra_mode_recharge_div
		nano += ultra_mode_cost * delta / ultra_mode_recharge_div
		if ultra_mode_usage < 0:
			ultra_mode_usage = 0
		remove_ultra_mode()
	else:
		remove_ultra_mode()

func remove_ultra_mode() -> void:
	if ultra_mode_on:
		move_speed = old_move_speed
		maniability = old_maniab
		turn_speed = old_turn_speed
		max_speed = old_max_speed
		ultra_mode_on = false
		ultra_mode_particles.emitting = false
		if ultra_mode_tween && ultra_mode_tween.is_valid():
			ultra_mode_tween.kill()
		ultra_mode_tween = create_tween()
		ultra_mode_tween.parallel().tween_property(ultra_mode_light,"energy",0,0.5)
		ultra_mode_tween.parallel().tween_property(ultra_mode_modulate,"color",Color(1,1,1),0.5)

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("auto_target"):
		current_target_id += 1
		do_target()
	if event.is_action_pressed("interact"):
		if dying:
			on_death()
		elif interaction:
			interaction.interact()
	if event.is_action_pressed("projectile_1"):
		change_bullet_type("bullet")
	if event.is_action_pressed("projectile_2"):
		change_bullet_type("bomb")

func change_bullet_type(type : String) -> void:
	bullet_preset.type = type
	bullet_type_lbl.text= bullet_preset.type

func do_target() -> void:
	var bodies : Array[Node2D] = auto_target.get_overlapping_bodies()
	if bodies.size() == 0:
		return
	if current_target_id >= bodies.size():
		current_target_id = 0
	target.change_target(bodies[current_target_id])

func on_target_lost() -> void:
	do_target()
		

func _on_trail_timer_timeout() -> void:
	trail.remove_point(0)
	trail.add_point(global_position,trail_length)
	trail_timer.start(trail_update_time)


func _on_auto_target_body_exited(node : Node2D) -> void:
	if node.get_node_or_null("target_node") == target.current_target && !auto_target.get_overlapping_bodies().has(node):
		target.current_target = null

signal end_anim_done

func on_death() -> void:
	Global.change_scene_to_file("end_screen.tscn")
	#GS.load_save(GS.auto_save_name)

func _on_anim_animation_finished(anim_name : String) -> void:
	match anim_name:
		"death":
			anim.play("death_message")
		"death_message":
			on_death()
		"end":
			end_anim_done.emit()

var can_ultra_mode : bool = true

func _on_ultra_mode_timer_timeout() -> void:
	can_ultra_mode = true
