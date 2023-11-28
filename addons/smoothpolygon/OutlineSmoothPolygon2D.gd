extends Node2D
class_name OutlineSmoothPolygon2D
##This class is not meant to be used as it is.

var outline : bool = false : set = set_outline
func set_outline(value : bool) -> void:
	outline = value
	queue_redraw()
	
var outlines : Array = [] : set = set_outlines
func set_outlines(value : Array) -> void:
	outlines = value
	queue_redraw()
	
var color : Color = Color(0,0,0) : set = set_color
func set_color(value : Color) -> void:
	color = value
	queue_redraw()
	
var width : float = 1 : set = set_width
func set_width(value : float) -> void:
	width = value
	queue_redraw()

func _draw() -> void:
	if outline:
		for line in outlines:
			draw_polyline(line,color,width)
