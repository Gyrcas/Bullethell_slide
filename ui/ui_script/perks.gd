extends Panel
class_name PerksWheel

@onready var shoot_timer : Timer = $shoot_timer_perk

var perks : Array[Perk] = []
var selected_arc : int = 0

var inner_radius : float = 100
var outer_radius : float = 500
var selecting_target : bool = false

var half_screen : Vector2

var target_controller : Vector2

func _ready() -> void:
	if GS.data.get("dash_aquired"):
		perks.append(DashPerk.new())
	visible = false
	Engine.time_scale = 1
	half_screen = get_viewport_rect().size / 2
	target_controller = half_screen

func draw_wheel() -> void:
	var inc : float = deg_to_rad(360) / perks.size()
	half_screen = get_viewport_rect().size / 2
	draw_arc(half_screen,inner_radius,0,TAU,100,Color(0,0,0))
	draw_arc(half_screen,outer_radius,0,TAU,100,Color(0,0,0))
	var center : float = inner_radius + (outer_radius - inner_radius) / 2
	var font : Font = Label.new().get_theme_font("")
	for i in perks.size():
		var rotate_angle : float = inc * i
		var center_angle : float = (rotate_angle - inc) + (rotate_angle - (rotate_angle - inc)) / 2
		draw_string(font,half_screen + Vector2(1,0).rotated(center_angle) * center,perks[i].name)
		if i == selected_arc:
			if perks.size() == 1:
				draw_arc_between_circle(half_screen,inner_radius,outer_radius,rotate_angle,(rotate_angle + inc)/2,32,Color(0.27058824896812, 0.27058824896812, 0.27058824896812, 0.50980395078659))
				draw_arc_between_circle(half_screen,inner_radius,outer_radius,(rotate_angle + inc)/2,rotate_angle + inc,32,Color(0.27058824896812, 0.27058824896812, 0.27058824896812, 0.50980395078659))
			else:
				draw_arc_between_circle(half_screen,inner_radius,outer_radius,rotate_angle,rotate_angle + inc,32,Color(0.27058824896812, 0.27058824896812, 0.27058824896812, 0.50980395078659))
		var dir : Vector2 = Vector2(1,0).rotated(rotate_angle)
		draw_line(
			half_screen + dir * inner_radius,
			half_screen + dir * outer_radius,
			Color(0,0,0)
		)

func _draw() -> void:
	if selecting_target:
		draw_circle(
			half_screen,
			perks[selected_arc].perk_range * Global.player.camera.zoom.x,
			Color(1, 0, 0, 0.1)
		)
		if Input.is_joy_known(0):
			draw_circle(target_controller,50,Color(0,0,0,0.2))
	else:
		draw_wheel()

func draw_arc_between_circle(center : Vector2, radius1 : float, radius2 : float, angle_from : float, angle_to : float,nb_points : int = 32, color : Color = Color(0,0,0)) -> void:
	var points_arc = PackedVector2Array()
	var inc = (angle_to - angle_from) / nb_points
	for i in nb_points + 1:
		points_arc.push_back(
			center + Vector2(1,0).rotated(angle_from + inc * i) * radius1
		)
	for i in nb_points + 1:
		var x : int = nb_points - i
		points_arc.push_back(
			center + Vector2(1,0).rotated(angle_from + inc * x) * radius2
		)
	draw_colored_polygon(points_arc,color)


const speed_target_controller : float = 5000
var joy_stick_dead_zone : float = 0.2

func _process(delta : float) -> void:
	if !visible:
		return
	if !Global.player.controllable:
		visible = false
		Global.tween_time_scale(1,time_trans_speed)
	var angle : float = Vector2(1,0).angle_to(half_screen.direction_to(get_local_mouse_position()))
	if angle < 0:
		angle += deg_to_rad(360)
	selected_arc = floor(angle / (deg_to_rad(360) / perks.size()))
	
	var controller_input : Vector2 = Vector2(
		Input.get_joy_axis(0,JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)
	)
	if abs(controller_input.x) < joy_stick_dead_zone:
		controller_input.x = 0
	if abs(controller_input.y) < joy_stick_dead_zone:
		controller_input.y = 0
	target_controller += controller_input * speed_target_controller * delta
	queue_redraw()

const time_trans_speed : float = 0.02

func _input(event : InputEvent) -> void:
	if Global.player.dying:
		visible = false
		Global.tween_time_scale(1,time_trans_speed)
		return
	if event.is_action_pressed("perks"):
		if !selecting_target:
			visible = !visible
			Global.tween_time_scale(0.1 if visible else 1.0,time_trans_speed)
		selecting_target = false
		if visible:
			target_controller = half_screen
		queue_redraw()
	if event.is_action_pressed("left_click") && visible:
		if selecting_target:
			var mouse : Vector2 = get_viewport().get_camera_2d().get_global_mouse_position()
			if Input.is_joy_known(0):
				mouse = (target_controller - half_screen) / Global.player.camera.zoom + Global.player.global_position
			
			if perks[selected_arc].nano_cost > Global.player.nano || perks[selected_arc].perk_range < Global.player.global_position.distance_to(mouse):
				return
			selecting_target = false
			if Global.player.can_shoot:
				(func():
					Global.player.can_shoot = false
					shoot_timer.start(0.5)
					await shoot_timer.timeout
					Global.player.can_shoot = true
				).call()
			visible = false
			Global.tween_time_scale(1,time_trans_speed)
			perks[selected_arc].execute(Global.player,{"target":mouse})
		elif perks.size() != 0:
			selecting_target = true
			queue_redraw()
