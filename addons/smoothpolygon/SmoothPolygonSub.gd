@tool
extends SmoothPolygon2D
class_name SmoothPolygonSub

@export var target_polygon : SmoothPolygon2D

func _ready() -> void:
	super()
	if !Engine.is_editor_hint() && target_polygon:
		target_polygon.do_polygon_operation(self,"clip",true)
