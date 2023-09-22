extends NavigationRegion2D
class_name PolygonNavigationRegion2D
## Try to generate a navigation polygon in all the space not used by a StaticPolygon2D. 
## Still work in progress.

func _ready() -> void:
	load_region(self)

# Merge all possible polygons from the array
func merge(pols : Array[PackedVector2Array]) -> Array[PackedVector2Array]:
	for pol in pols:
		for pol2 in pols:
			if pol == pol2:
				continue
			if !UT.get_intersections_polygons(pol,pol2).is_empty():
				pols.erase(pol)
				pols.erase(pol2)
				pols.append(Geometry2D.merge_polygons(pol,pol2)[0])
				return merge(pols)
	return pols

# Generate navigation polygon for the region
func load_region(region : NavigationRegion2D) -> void:
	region.navigation_polygon = navigation_polygon
	var pols : Array[PackedVector2Array] = []
	for child in get_children():
		if UT._is_class(child,"SmoothStaticPolygon2D"):
			if Engine.is_editor_hint():
				pols.append(child.get_child(0).polygon)
			else:
				pols.append(child.polygon)
	pols = merge(pols)
	for pol in pols:
		region.navigation_polygon.add_outline(pol)
	region.navigation_polygon.make_polygons_from_outlines()
