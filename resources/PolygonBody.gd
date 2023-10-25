@tool
extends Polygon2D
class_name PolygonBody

@export var outline : Color = Color(0,0,0)
@export var outline_width : float = 3

func _draw() -> void:
	for i in range(1 , polygon.size()):
		draw_line(polygon[i-1] , polygon[i], outline , outline_width)
	draw_line(polygon[polygon.size() - 1] , polygon[0], outline , outline_width)
