extends Area2D

signal asteroid_added(new_asteroid)

var blank_asteroid_scene: PackedScene = preload("res://scenes/Asteroids/asteroid_blank.tscn")

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
	# destruction_area.position = transform.basis_xform_inv(destruction_area.position - global_position)

	var new_asteroids: Array[PackedVector2Array] = Geometry2D.clip_polygons($Polygon2D.polygon, localized_rotated_destruct_area.polygon)

	for i in new_asteroids.size():

		if i > 0:

			print("asteroid added - asteroid")
			var asteroid_new: Area2D = blank_asteroid_scene.instantiate()
			asteroid_new.find_child("Polygon2D").polygon = new_asteroids[i]
			asteroid_new.find_child("CollisionPolygon2D").polygon = new_asteroids[i]
			emit_signal("asteroid_added", asteroid_new)
		else:

			$Polygon2D.polygon = new_asteroids[i]
			$CollisionPolygon2D.set_deferred("polygon", new_asteroids[0])

		



func localize_and_rotate(destruction_area) -> Polygon2D:
	
	var offset_poly = Polygon2D.new()
	offset_poly.global_position = Vector2.ZERO

	var new_poly_points: Array[Vector2] = []

	for point in destruction_area.polygon:
	
		# Localize the polygons point.
		var localized_position: Vector2 = destruction_area.global_position - global_position

		# Rotate the polygon point.
		var rotated_position: Vector2 = Vector2()
		rotated_position.x = (point.x * cos(destruction_area.rotation)) - (point.y * sin(destruction_area.rotation))
		rotated_position.y = (point.y * cos(destruction_area.rotation)) + (point.x * sin(destruction_area.rotation))

		# Combine the localized point with the rotation
		# and add them into the new_poly_points array.
		new_poly_points.append(localized_position + rotated_position)
	
	offset_poly.polygon = PackedVector2Array(new_poly_points)

	return offset_poly
