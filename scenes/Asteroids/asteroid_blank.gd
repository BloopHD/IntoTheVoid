extends Area2D

signal asteroid_added(new_asteroid)

func _ready():
	calculate_polygon_properties()


func calculate_polygon_properties():
	var center = Vector2.ZERO
	var area = 0
	var asteroid_points: PackedVector2Array = $Polygon2D.polygon

	for i in asteroid_points.size():
		
		var i_plus_one = i + 1
		if i_plus_one >= asteroid_points.size():
			i_plus_one = 0
		
		var curr = asteroid_points[i]
		var next = asteroid_points[i_plus_one]

		area += (curr.x * next.y) - (next.x * curr.y)

		center.x += (curr.x + next.x) * ((curr.x * next.y) - (next.x * curr.y))
		center.y -= (curr.y + next.y) * ((curr.y * next.x) - (next.y * curr.x))



	area = area / 2
	center = (center / 6) / area





func clip(destruction_area):

	var localized_rotated_destruct_area: Polygon2D = localize_and_rotate(destruction_area)

	var new_asteroids: Array[PackedVector2Array] = Geometry2D.clip_polygons($Polygon2D.polygon, localized_rotated_destruct_area.polygon)

	for new_asteroid in new_asteroids:

		if new_asteroids.size() == 1:
			$Polygon2D.polygon = new_asteroids[0]
			$CollisionPolygon2D.set_deferred("polygon", new_asteroids[0])


		emit_signal("asteroid_added", new_asteroid)
		


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
