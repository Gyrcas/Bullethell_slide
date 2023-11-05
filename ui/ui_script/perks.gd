extends Control

var perks : Array = [1,1,1,1,1,1,1,1,1]
var selected_arc : int = 0

var inner_radius : float = 100
var outer_radius : float = 500

var half_screen : Vector2

func _ready() -> void:
	half_screen = get_viewport_rect().size / 2

func _draw() -> void:
	var inc : float = deg_to_rad(360) / perks.size()
	half_screen = get_viewport_rect().size / 2
	draw_arc(half_screen,inner_radius,0,TAU,100,Color(0,0,0))
	draw_arc(half_screen,outer_radius,0,TAU,100,Color(0,0,0))
	for i in perks.size():
		var rotate_angle : float = inc * i
		if i == selected_arc:
			draw_arc_between_circle(half_screen,inner_radius,outer_radius,rotate_angle,rotate_angle + inc,32,Color(0.27058824896812, 0.27058824896812, 0.27058824896812, 0.50980395078659))
		var dir : Vector2 = Vector2(1,0).rotated(rotate_angle)
		draw_line(
			half_screen + dir * inner_radius,
			half_screen + dir * outer_radius,
			Color(0,0,0)
		)

func draw_arc_between_circle(center : Vector2, radius1 : float, radius2 : float, angle_from : float, angle_to : float,nb_points : int = 32, color : Color = Color(0,0,0)) -> void:
	var points_arc = PackedVector2Array()
	var inc = (angle_to - angle_from) / nb_points
	for i in range(nb_points + 1):
		var point = center + Vector2(1,0).rotated(angle_from + inc * i) * radius1
		points_arc.push_back(point)
	for i in range(nb_points + 1):
		var x = nb_points + 1 - i
		var point = center + Vector2(1,0).rotated(angle_from + inc * x) * radius2
		points_arc.push_back(point)
	draw_colored_polygon(points_arc,color)

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var colors = PackedColorArray([color])
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func _process(_delta : float) -> void:
	if !visible:
		return
	var angle : float = Vector2(1,0).angle_to(half_screen.direction_to(get_global_mouse_position()))
	if angle < 0:
		angle += deg_to_rad(360)
	var last_selected : int = selected_arc
	selected_arc = floor(angle / (deg_to_rad(360) / perks.size()))
	if last_selected != selected_arc:
		queue_redraw()
	
func _input(event : InputEvent) -> void:
	if event.is_action_pressed("perks"):
		visible = !visible
		Engine.time_scale = 0.1 if visible else 1.0
		
