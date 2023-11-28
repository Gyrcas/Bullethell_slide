@tool
extends SmoothPolygon2D
class_name SmoothPolygonSub

@export var targets_polygon : Array[SmoothPolygon2D] = []

@export var delete_self : bool = true

@export var operate_on_ready : bool = true

func operate() -> void:
	if !Engine.is_editor_hint() && !targets_polygon.is_empty():
		for pol in targets_polygon:
			pol.do_polygon_operation.call_deferred(self,"clip",false)
		if delete_self:
			queue_free()

func _ready() -> void:
	super()
	if operate_on_ready:
		operate()
