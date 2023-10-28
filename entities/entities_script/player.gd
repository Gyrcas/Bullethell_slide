extends MoverEntity
class_name Player

# Nodes
@onready var body : Polygon2D = $body
@onready var target : Node2D = $target
@onready var camera : Camera2D = $camera
@onready var health_bar : TextureProgressBar = $camera/ui/hud/health
@onready var nano_bar : TextureProgressBar = $camera/ui/hud/nanos
@onready var interaction_lbl : Label = $camera/ui/interaction

var interaction : Node = null : set = set_interaction

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
	health = value
	var tween : Tween = create_tween()
	tween.tween_property(
		health_bar,"value",health / health_max * health_bar.max_value,0.1
	)
	if health <= 0:
		pass

func set_nano(value : int) -> void:
	nano = value
	var tween : Tween = create_tween()
	tween.tween_property(
		nano_bar,"value",float(nano) / nano_max * nano_bar.max_value,0.1)

func _ready() -> void:
	check_dependance()
	# Create trail
	trail.points = []
	for i in trail_length:
		trail.add_point(global_position,i)
	
	NodeLinker.player = self
	trail_timer.start(trail_update_time)
	
	target.connect("target_lost",on_target_lost)
	
	auto_target.set_collision_mask_value(NodeLinker.auto_target_collision_level,true)
	
	bullet_preset.sender = self
	bullet_preset.target_node = target

func _physics_process(delta : float) -> void:
	# Get movement inputs
	var move : int = int(Input.get_axis("down","up"))
	var turn : int = int(Input.get_axis("left","right"))
	var speed : float = velocity.x / velocity.normalized().x
	speed = 0.0 if is_nan(speed) else speed
	
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
		Input.is_action_pressed("left_click") && can_shoot && nano >= bullet_preset.nano
	)
	
	trail.global_position = Vector2.ZERO
	trail.rotation = -rotation
	trail.points[trail.points.size() - 1] = global_position
	
	auto_target.global_position = camera.get_screen_center_position()


#Auto Target----------------------------------------------
var target_zone_width : float = 300
@onready var auto_target : Area2D = $auto_target
var current_target_id : int = -1

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("auto_target"):
		current_target_id += 1
		do_target()
	elif event.is_action_pressed("interact") && interaction:
		interaction.interact()
	elif event.is_action_pressed("projectile_1"):
		bullet_preset.type = "default"
	elif event.is_action_pressed("projectile_2"):
		bullet_preset.type = "bomb"

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
