@tool
extends EditorPlugin


func _enter_tree() -> void:
	const path : String = "res://addons/SmoothPolygon/"
	add_custom_type("SmoothPolygon2D","Polygon2D",load(path + "SmoothPolygon2D.gd"),load(path + "icons/icon.svg"))
	add_custom_type("SmoothStaticPolygon2D","SmoothPolygon2D",load(path + "SmoothStaticPolygon2D.gd"),load(path + "icons/icon.svg"))
	add_custom_type("OutlineSmoothPolygon2D","Node2D",load(path + "OutlineSmoothPolygon2D.gd"),load(path + "icons/icon.svg"))
	add_custom_type("PolygonNavigationRegion2D","NavigationRegion2D",load(path + "PolygonNavigationRegion2D.gd"),load(path + "icons/icon.svg"))


func _exit_tree() -> void:
	remove_custom_type("SmoothPolygon2D")
	remove_custom_type("SmoothStaticPolygon2D")
	remove_custom_type("OutlineSmoothPolygon2D")
	remove_custom_type("PolygonNavigationRegion2D")
	
	
