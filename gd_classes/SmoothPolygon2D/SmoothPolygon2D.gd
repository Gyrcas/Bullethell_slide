@tool
extends Polygon2D 
class_name SmoothPolygon2D
## Will smoothen the transition between each points of the polygon

@export var base_polygon : PackedVector2Array = []

@export var polygon_color : Color = color : set = set_polygon_color

func set_polygon_color(value : Color) -> void:
	polygon_color = value
	queue_redraw()

func _set(property : StringName, value : Variant) -> bool:
	match(property):
		"polygon":
			polygon = value
			base_polygon = polygon
			return true
		"color":
			if Engine.is_editor_hint():
				color.a = 0;
				return true
	return false

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_colored_polygon(smoothen_polygon(polygon).polygon,polygon_color)
	else:
		var results : Dictionary = smoothen_polygon(base_polygon)
		polygon = results.polygon
		color = polygon_color

## How far the new smoothed polygon can be from the old polygon lines
@export var allowed_distance : float = 5000 : set = set_allowed_distance

func set_allowed_distance(value : float) -> void:
	allowed_distance = value
	queue_redraw()

## Lenght of each new segment. The smaller it is, the smoother it is
@export var intervale : float = 10 : set = set_interval

func set_interval(value : float) -> void:
	intervale = value
	queue_redraw()

## Will ignore the segment after the point during the smoothing
@export var ignore_points : PackedInt32Array = [] : set = set_ignore_points

func set_ignore_points(value : PackedInt32Array) -> void:
	ignore_points = value
	queue_redraw()

# Contains current custom class and ancestor custom classes. Mainly used with singleton UT to verify 
# classes
var _class : PackedStringArray = []

func _init() -> void:
	_class.append("SmoothPolygon2D")

func _ready() -> void:
	if !Engine.is_editor_hint():
		var results : Dictionary = smoothen_polygon(base_polygon)
		polygon = results.polygon
		color = polygon_color
	else:
		color.a = 0

#Smooth the given polygon by using a curve2D to make a smooth transition between the points
func smoothen_polygon(pol : PackedVector2Array) -> Dictionary:
	var curve : Curve2D = Curve2D.new()
	curve.bake_interval = allowed_distance
	for point in pol:
		curve.add_point(point)
	curve.add_point(pol[0])
	var last_pos : Vector2 = pol[0]
	var pos : Vector2 = pol[1]
	var top : float = pol[0].y
	var bottom : float = pol[0].y
	var left : float = pol[0].x
	var right : float = pol[0].x
	pol = []
	var new_poly : PackedVector2Array = []
	var t : float = 0.0
	var cur_point : int = 0
	while last_pos != pos:
		t += intervale
		last_pos = pos
		pos = curve.sample_baked(t,true)
		if cur_point + 1 < curve.point_count:
			if t > curve.get_closest_offset(curve.get_point_position(cur_point + 1)):
				cur_point += 1
		if ignore_points.has(cur_point):
			if cur_point + 1 < curve.point_count - 1:
				cur_point += 1
				pos = curve.get_point_position(cur_point)
				t = curve.get_closest_offset(curve.get_point_position(cur_point))
			else:
				pos = curve.get_point_position(0)
				t = curve.get_closest_offset(curve.get_point_position(0))
				break
		if pos.y < top:
			top = pos.y
		elif pos.y > bottom:
			bottom = pos.y
		if pos.x > right:
			right = pos.x
		elif pos.x < left:
			left = pos.x
		new_poly.append(pos)
	return {
		"polygon":new_poly,
		"top":top+global_position.y,
		"bottom":bottom+global_position.y,
		"left":left+global_position.x,
		"right":right+global_position.x}
