@tool
extends Polygon2D 
class_name SmoothPolygon2D
## Will smoothen the transition between each points of the polygon

## How far the new smoothed polygon can be from the old polygon lines
@export var allowed_distance : float = 5000 : set = set_allowed_distance

func set_allowed_distance(value : float) -> void:
	allowed_distance = value
	queue_redraw()

## Lenght of each new segment. The smaller it is, the smoother it is, but performances will suffer
@export var intervale : float = 10 : set = set_interval

func set_interval(value : float) -> void:
	intervale = value
	queue_redraw()

## Will ignore the segment after the point during the smoothing
@export var ignore_points : PackedInt32Array = [] : set = set_ignore_points

func set_ignore_points(value : PackedInt32Array) -> void:
	ignore_points = value
	queue_redraw()

@export_group("outline")

## Use the outline?
@export var outline : bool = false : set = set_outline

func set_outline(value : bool) -> void:
	outline = value
	outline_node.outline = value

## Color of the outline
@export var outline_color : Color = Color(0,0,0) : set = set_outline_color

func set_outline_color(value : Color) -> void:
	outline_color = value
	outline_node.color = value

## Width of the outline
@export var outline_width : int = 1 : set = set_outline_width

func set_outline_width(value : int) -> void:
	outline_width = value
	outline_node.width = value

## Will skip the vertex of the point while doing outline
@export var ignore_points_outline : PackedInt32Array = [] : set = set_ignore_points_outline

func set_ignore_points_outline(value : PackedInt32Array) -> void:
	ignore_points_outline = value
	if !Engine.is_editor_hint():
		return
	var results : Dictionary = smoothen_polygon(polygon)
	outline_node.outlines = results.outlines

@export_group("DON'T TOUCH")
## Do not change value of this variable
@export var smoothed_pol : PackedVector2Array = []

@export var outlines_array : Array[PackedVector2Array] = []

var outline_node : OutlineSmoothPolygon2D = OutlineSmoothPolygon2D.new()

# Contains current custom class and ancestor custom classes. Mainly used with singleton UT to verify 
# classes
var _class : PackedStringArray = []

func _init() -> void:
	_class.append("SmoothPolygon2D")

func _set(property : StringName, value : Variant) -> bool:
	match(property):
		"color":
			if Engine.is_editor_hint():
				color.a = 0;
				return true
	return false

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	var results = smoothen_polygon(polygon)
	smoothed_pol = results.polygon
	draw_colored_polygon(smoothed_pol,modulate)
	outlines_array = results.outlines
	
	outline_node.outlines = outlines_array

func _ready() -> void:
	if !Engine.is_editor_hint():
		polygon = smoothed_pol
		outline_node.outlines = outlines_array.duplicate()
		smoothed_pol.clear()
		outlines_array.clear()
		color = modulate
	else:
		color.a = 0
	add_child(outline_node)

#Smooth the given polygon by using a curve2D to make a smooth transition between the points.
#Return the smoothed polygon as "polygon", the rect values as "top","bottom","left" and "right",
#and an array containing multiple PackedVector2Array making the different outlines in "outlines"
func smoothen_polygon(pol : PackedVector2Array) -> Dictionary:
	#Return if polygon is empty
	if pol.is_empty():
		return {"polygon":[],"outlines":[],"top":0,"bottom":0,"left":0,"right":0}
	#Create curve with points of the polygon
	var curve : Curve2D = Curve2D.new()
	curve.bake_interval = allowed_distance
	for point in pol:
		curve.add_point(point)
	curve.add_point(pol[0])
	#Outline
	var outlines : Array[PackedVector2Array] = []
	var current_outline : PackedVector2Array = []
	#Positions of t
	var last_pos : Vector2 = pol[0]
	var pos : Vector2 = pol[1]
	#Rectangle of Polygon
	var top : float = pol[0].y
	var bottom : float = pol[0].y
	var left : float = pol[0].x
	var right : float = pol[0].x
	
	var new_poly : PackedVector2Array = []
	
	var t : float = 0.0
	
	var cur_point : int = 0
	#While curve not finished
	while last_pos != pos:
		t += intervale
		last_pos = pos
		#Get pos from the curve offset t
		pos = curve.sample_baked(t,true)
		#Check if there is any actual possible change to the form. 
		#If not, skip to the next
		if (cur_point + 1 < curve.point_count &&
			curve.get_point_position(cur_point).distance_to(pos) > allowed_distance && 
			curve.get_point_position(cur_point + 1).distance_to(pos) > allowed_distance):
			t += curve.get_point_position(cur_point + 1).distance_to(pos) - allowed_distance
			continue
		#Check if closer to the next original point
		if (cur_point + 1 < curve.point_count && 
			t > curve.get_closest_offset(curve.get_point_position(cur_point + 1))):
			cur_point += 1
		#Skip point if is in ignore_points
		if ignore_points.has(cur_point):
			if cur_point + 1 < curve.point_count - 1:
				cur_point += 1
				var p : Vector2 = curve.get_point_position(cur_point)
				pos = curve.get_point_position(cur_point)
				t = curve.get_closest_offset(curve.get_point_position(cur_point))
			else:
				pos = curve.get_point_position(0)
				t = curve.get_closest_offset(curve.get_point_position(0))
				break
		#Manage the point skip of outline
		if !ignore_points_outline.has(cur_point):
			current_outline.append(pos)
		elif !current_outline.is_empty():
			outlines.append(current_outline)
			current_outline = []
		#Check for new coord rect
		if pos.y < top:
			top = pos.y
		elif pos.y > bottom:
			bottom = pos.y
		if pos.x > right:
			right = pos.x
		elif pos.x < left:
			left = pos.x
			
		new_poly.append(pos)
	#Add last outline to outline array
	if !current_outline.is_empty():
		outlines.append(current_outline)
		current_outline = []
	
	#Return the new polygon, the rect and the outlines
	return {
		"polygon":new_poly,
		"top":top+global_position.y,
		"bottom":bottom+global_position.y,
		"left":left+global_position.x,
		"right":right+global_position.x,
		"outlines":outlines}
