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
const min_speed_reduct : float = 3
const col_speed_reduct : float = 0.5
const max_speed_bouce : float = 4

func set_health(value : float) -> void:
	if value < health:
		Global.shake_camera(camera,Vector2(100,100),25,0.01)
	health = value
	var tween : Tween = create_tween()
	tween.tween_property(
		health_bar,"value",health / health_max * health_bar.max_value,0.1
	)
	if health <= 0 && !dying:
		die()

func set_nano(value : float) -> void:
	nano = value
	var tween : Tween = create_tween()
	tween.tween_property(
		nano_bar,"value",float(nano) / nano_max * nano_bar.max_value,0.1)

var thruster_sound_id : String

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

func _physics_process(delta : float) -> void:
	# Get movement inputs
	var move : int = int(Input.get_axis("down","up"))
	var turn : int = int(Input.get_axis("left","right"))
	if dying || !controllable:
		move = 0
		turn = 0
	var speed : float = velocity.x / velocity.normalized().x
	if is_nan(speed):
		speed = 0.0
	# Execute velocity and get collision
	var collision : Variant = do_move(move,turn,delta, speed)
	# If collision, manage collision
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		velocity += collision.get_normal() * 3
		if speed >= min_speed_reduct:
			velocity *= col_speed_reduct
		if speed > max_speed_bouce:
			velocity = velocity.normalized() * max_speed_bouce
		
	shoot(
		Input.is_action_pressed("left_click") && can_shoot && nano >= bullet_preset.nano && !perks_wheel.visible && controllable
	)
	
	trail.points[trail.points.size() - 1] = global_position
	
	auto_target.global_position = camera.get_screen_center_position()

#Auto Target----------------------------------------------
var target_zone_width : float = 300
@onready var auto_target : Area2D = $auto_target
var current_target_id : int = -1

func _input(event : InputEvent) -> void:
	if !controllable:
		return
	if event.is_action_pressed("auto_target"):
		current_target_id += 1
		do_target()
	if event.is_action_pressed("interact"):
		if interaction:
			interaction.interact()
		elif dying:
			GS.load_save(GS.auto_save_name)
	if event.is_action_pressed("projectile_1"):
		change_bullet_type("default")
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

func _on_anim_animation_finished(anim_name : String) -> void:
	match anim_name:
		"death":
			anim.play("death_message")
		"death_message":
			GS.load_save(GS.auto_save_name)
		"end":
			end_anim_done.emit()
