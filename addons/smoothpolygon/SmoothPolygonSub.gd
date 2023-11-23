@tool
extends SmoothPolygon2D
class_name SmoothPolygonSub

@export var targets_polygon : Array[SmoothPolygon2D] = []

@export var delete_self : bool = true

func _ready() -> void:
	super()
	if !Engine.is_editor_hint() && !targets_polygon.is_empty():
		for pol in targets_polygon:
			pol.do_polygon_operation.call_deferred(self,"clip",delete_self)
