extends Area2D

func clip(destruction_area):

	var localized_rotated_destruct_area: Polygon2D = localize_and_rotate(destruction_area)

	var res = Geometry2D.clip_polygons($Polygon2D.polygon, localized_rotated_destruct_area.polygon)

	$Polygon2D.polygon = res[0]
	$CollisionPolygon2D.set_deferred("polygon", res[0])


func localize_and_rotate(destruction_area) -> Polygon2D:
	
	var offset_poly = Polygon2D.new()
	offset_poly.global_position = Vector2.ZERO

	var new_values = []

	for point in destruction_area.polygon:
	
		var rotated_vector: Vector2 = Vector2()
		rotated_vector.x = (point.x * cos(destruction_area.rotation)) - (point.y * sin(destruction_area.rotation))
		rotated_vector.y = (point.y * cos(destruction_area.rotation)) + (point.x * sin(destruction_area.rotation))
		
		new_values.append(rotated_vector+destruction_area.global_position)
	
	offset_poly.polygon = PackedVector2Array(new_values)

	return offset_poly
