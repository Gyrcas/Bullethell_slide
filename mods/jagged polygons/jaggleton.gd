extends Node

func _ready() -> void:
	get_tree().connect("node_added",check_node)


func check_node(node):
	if node is SmoothPolygon2D:
		if !node.is_node_ready():
			await node.ready
		node.polygon = node.base_polygon
