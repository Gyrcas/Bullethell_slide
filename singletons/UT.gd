@tool
extends Node
#class_name UT
## All kinds of useful method

# Get the main scene
# return -> node that is the main scene
func get_main() -> Node:
	var id : int = get_tree().get_root().get_child_count() - 1
	return get_tree().get_root().get_child(id)


# get the average pf the given values
# parameters:
# 	values -> array of float or int
# return -> average of the given values
func avg(values : Array) -> float:
	if values.is_empty():
		return 0
	var sum : float = 0
	for value in values:
		sum += value
	return sum / values.size()


# Remove all children of a node
# parameters:
# 	node -> the node who will lose all their children
func remove_children(node : Node) -> void:
	if !node:
		push_error("Cannot remove children of null")
		return
	for child in node.get_children():
		child.queue_free()


func merge_dictionaries(first : Dictionary, second : Dictionary) -> Dictionary:
	for key in second.keys():
		first[key] = second[key]
	return first


const variant_type : Dictionary = {
	"null":Variant.Type.TYPE_NIL,
	"bool":Variant.Type.TYPE_BOOL,
	"int":Variant.Type.TYPE_INT,
	"float":Variant.Type.TYPE_FLOAT,
	"String":Variant.Type.TYPE_STRING,
	"Vector2":Variant.Type.TYPE_VECTOR2,
	"Vector2i":Variant.Type.TYPE_VECTOR2I,
	"Rect2":Variant.Type.TYPE_RECT2,
	"Rect2i":Variant.Type.TYPE_RECT2I,
	"Vector3":Variant.Type.TYPE_VECTOR3,
	"Vector3i":Variant.Type.TYPE_VECTOR3I,
	"Transform2D":Variant.Type.TYPE_TRANSFORM2D,
	"Vector4":Variant.Type.TYPE_VECTOR4,
	"Vector4i":Variant.Type.TYPE_VECTOR4I,
	"Plane":Variant.Type.TYPE_PLANE,
	"Quaternion":Variant.Type.TYPE_QUATERNION,
	"AABB":Variant.Type.TYPE_AABB,
	"Basis":Variant.Type.TYPE_BASIS,
	"Transform3D":Variant.Type.TYPE_TRANSFORM3D,
	"Projection":Variant.Type.TYPE_PROJECTION,
	"Color":Variant.Type.TYPE_COLOR,
	"StringName":Variant.Type.TYPE_STRING_NAME,
	"NodePath":Variant.Type.TYPE_NODE_PATH,
	"RID":Variant.Type.TYPE_RID,
	"Object":Variant.Type.TYPE_OBJECT,
	"Callable":Variant.Type.TYPE_CALLABLE,
	"Signal":Variant.Type.TYPE_SIGNAL,
	"Dictionary":Variant.Type.TYPE_DICTIONARY,
	"Array":Variant.Type.TYPE_ARRAY,
	"PackedByteArray":Variant.Type.TYPE_PACKED_BYTE_ARRAY,
	"PackedInt32Array":Variant.Type.TYPE_PACKED_INT32_ARRAY,
	"PackedInt64Array":Variant.Type.TYPE_PACKED_INT64_ARRAY,
	"PackedFloat32Array":Variant.Type.TYPE_PACKED_FLOAT32_ARRAY,
	"PackedFloat64Array":Variant.Type.TYPE_PACKED_FLOAT64_ARRAY,
	"PackedStringArray":Variant.Type.TYPE_PACKED_STRING_ARRAY,
	"PackedVector2Array":Variant.Type.TYPE_PACKED_VECTOR2_ARRAY,
	"PackedVector3Array":Variant.Type.TYPE_PACKED_VECTOR3_ARRAY,
	"PackedColorArray":Variant.Type.TYPE_PACKED_COLOR_ARRAY
}

func is_type(variable : Variant, type_name : String) -> bool:
	if variant_type.has(type_name):
		return typeof(variable) == variant_type[type_name]
	return false
		
func _get_class(node : Node) -> String:
	if node.get("_class"):
		if is_type(node._class,"String"):
			return node._class
		if is_type(node._class,"PackedStringArray"):
			return node._class[node._class.size() - 1]
	return node.get_class()

func get_class_ancestors(node : Node) -> PackedStringArray:
	if node.get("_class"):
		if is_type(node._class,"PackedStringArray"):
			return node._class
	return [] 

func has_class_ancestor(node : Node, class_ancestor : String) -> bool:
	return get_class_ancestors(node).has(class_ancestor)

func _is_class(node : Node, classname : String) -> bool:
	return _get_class(node) == classname

func get_parent_child_id(node : Node) -> int:
	var parent : Node = node.get_parent()
	for i in parent.get_child_count():
		if parent.get_child(i) == node:
			return i
	return -1

func get_intersections_polygons(pol1 : PackedVector2Array, pol2 : PackedVector2Array) -> PackedVector2Array:
	var result: PackedVector2Array = []

	var p11: Vector2 
	var p12: Vector2
	var p21: Vector2
	var p22: Vector2

	# nested loops checking intersections 
	# between all segments of both polygons
	for i in range(0, pol1.size()):
		p11 = pol1[i]
		p12 = pol1[i + 1] if i + 1 < pol1.size() else pol1[0]
		for j in range(0, pol2.size()):
			p21 = pol2[j]
			p22 = pol2[j + 1] if j + 1 < pol2.size() else pol2[0]
			# use Geometry function to evaluate intersections
			var intersect = Geometry2D.segment_intersects_segment(p11, p12, p21, p22)
			if intersect != null: result.append(intersect)
	return result

func framefreeze(duration : float) -> void:
	get_tree().paused = true
	await get_tree().create_timer(duration).timeout
	get_tree().paused = false
