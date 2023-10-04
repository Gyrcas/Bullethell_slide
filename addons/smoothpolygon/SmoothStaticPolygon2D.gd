@tool
extends SmoothPolygon2D
class_name SmoothStaticPolygon2D
## Adds a collision to the smoothed polygon from SmoothPolygon2D

var col : CollisionPolygon2D = CollisionPolygon2D.new()

func _init() -> void:
	super()
	_class.append("SmoothStaticPolygon2D")

func _ready() -> void:
	super()
	if !Engine.is_editor_hint():
		var bod : StaticBody2D = StaticBody2D.new()
		add_child(bod)
		bod.add_child(col)
		col.polygon = polygon

func _set(property : StringName, value : Variant) -> bool:
	var parent_return : bool = super(property, value)
	if property == "polygon":
		if !Engine.is_editor_hint():
			col.polygon = value
			return true
	return parent_return
	
