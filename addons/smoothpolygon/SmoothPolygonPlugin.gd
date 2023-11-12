@tool
extends EditorPlugin

func _exit_tree() -> void:
	remove_custom_type("SmoothPolygon2D")
	remove_custom_type("SmoothStaticPolygon2D")
	remove_custom_type("OutlineSmoothPolygon2D")
	
	
