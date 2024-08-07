extends RigidBody2D

var new_asteroid_scene: PackedScene = load("res://scenes/asteroid/asteroid.tscn")

var minimum_size: float = 1250.0

var area: float

func _ready() -> void:

	calculate_polygon_properties()
	check_size_requirment()
		

func calculate_polygon_properties() -> void:

	var center: Vector2 = Vector2.ZERO
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


func check_size_requirment():
	
	if area <= minimum_size:

		queue_free()


func clip(destruction_area) -> void:

	# var localized_rotated_destruct_area: Polygon2D = localize_and_rotate(destruction_area)
	# var new_asteroids: Array[PackedVector2Array] = Geometry2D.clip_polygons($Polygon2D.polygon, localized_rotated_destruct_area.polygon)
	
	destruction_area.position = transform.basis_xform_inv(destruction_area.global_position - global_position)
	var new_asteroids: Array[PackedVector2Array] = Geometry2D.clip_polygons($Polygon2D.polygon, destruction_area.polygon)	

	for i in new_asteroids.size():

		if i > 0:

			var asteroid_new: RigidBody2D = new_asteroid_scene.instantiate()

			asteroid_new.find_child("Polygon2D").polygon = new_asteroids[i]
			asteroid_new.find_child("CollisionPolygon2D").polygon = new_asteroids[i]
			asteroid_new.global_position = global_position

			get_parent().call_deferred("add_child", asteroid_new)

		else:

			$Polygon2D.polygon = new_asteroids[i]

			calculate_polygon_properties()
			check_size_requirment()

			$CollisionPolygon2D.set_deferred("polygon", new_asteroids[i])


func localize_and_rotate(destruction_area) -> Polygon2D:
	
	var offset_poly = Polygon2D.new()
	offset_poly.global_position = Vector2.ZERO

	var dest_area_rotation: float = destruction_area.global_rotation
	var new_poly_points: Array[Vector2] = []

	for point in destruction_area.polygon:
	
		# Localize the polygons point.
		var localized_position: Vector2 = (destruction_area.global_position - global_position)

		# Rotate the polygon point.
		var rotated_position: Vector2 = Vector2()
		rotated_position.x = (point.x * cos(dest_area_rotation)) - (point.y * sin(dest_area_rotation))
		rotated_position.y = (point.y * cos(dest_area_rotation)) + (point.x * sin(dest_area_rotation))

		# Combine the localized point with the rotation
		# and add them into the new_poly_points array.
		new_poly_points.append(localized_position + rotated_position)
	
	offset_poly.polygon = PackedVector2Array(new_poly_points)

	return offset_poly
