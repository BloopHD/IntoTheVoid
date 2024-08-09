extends RigidBody2D

var new_asteroid_scene: PackedScene = load("res://scenes/asteroid/asteroid.tscn")

var minimum_size: float = 1250.0

var area: float

func _ready() -> void:

	calculate_polygon_properties()
	check_size_requirment()
		

func _physics_process(delta):

	#rotate(0.2 * delta)
	

	# print("GP: ", global_position)
	# print("P:  ", position)
	# print("PGP: ", $Polygon2D.global_position)
	# print("PP:   ", $Polygon2D.position)
	# print("--------------------------")
	# print("GR:  ", global_rotation)
	# print("R:   ", rotation)
	# print("PGR: ", $Polygon2D.global_rotation)
	# print("PR:   ", $Polygon2D.rotation)
	# print("--------------------------")


	pass


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
	# # var poly = $Polygon2D
	# # poly.rotate(rotation)
	# # print("r ", poly.rotation)
	# var new_asteroids: Array[PackedVector2Array] = Geometry2D.clip_polygons($Polygon2D.polygon, localized_rotated_destruct_area.polygon)
	
	var transformed_projectile_position = transform.basis_xform_inv(destruction_area.global_position - global_position)

	# print("Asteroid: ", global_position)
	# print("Asteroid: ", position)
	# print("Laser:    ", destruction_area.global_position)
	# print("Transform ", transformed_projectile_position)
	# print("---------------")

	# destruction_area.global_position = transformed_projectile_position
	# print("Laser:    ", destruction_area.global_position)
	# print("---------------")
	
	
	var test: Polygon2D = localize(destruction_area, transformed_projectile_position)
	
	print(destruction_area.polygon)
	print(test.polygon)

	
	
	# destruction_area.position = transform.basis_xform_inv(destruction_area.global_position - global_position)
	var new_asteroids: Array[PackedVector2Array] = Geometry2D.clip_polygons($Polygon2D.polygon, test.polygon)	

	# print($Polygon2D.polygon)
	# print(new_asteroids[0])
	# print("---")	
	# print(destruction_area.polygon)
	# print(new_asteroids[1])
	# print("---------------")	

	for i in new_asteroids.size():

		#print(i)
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


func localize(destruction_area, new_transform: Vector2 ) -> Polygon2D:

	var offset_poly = Polygon2D.new()
	offset_poly.global_position = Vector2.ZERO

	var new_poly_points: Array[Vector2] = []

	var dest_area_rotation: float = destruction_area.global_rotation
	print((dest_area_rotation))

	for point in destruction_area.polygon:
	
		# Localize the polygons point.
		var localized_position: Vector2 = (point + new_transform)

		# var rotated_position: Vector2 = Vector2()
		# rotated_position.x = (point.x * cos(dest_area_rotation)) - (point.y * sin(dest_area_rotation))
		# rotated_position.y = (point.y * cos(dest_area_rotation)) + (point.x * sin(dest_area_rotation))

		new_poly_points.append(localized_position)
	
	offset_poly.polygon = PackedVector2Array(new_poly_points)

	return offset_poly


func localize_and_rotate(destruction_area, new_transform: Vector2) -> Polygon2D:
	
	var offset_poly = Polygon2D.new()
	offset_poly.global_position = Vector2.ZERO

	var dest_area_rotation: float = destruction_area.global_rotation
	var new_poly_points: Array[Vector2] = []

	# print("DA.GP: ", destruction_area.global_position)
	# print("GP   :  ", global_position)
	# print("GP   :  ", destruction_area.global_position - global_position)
	# print("--------------------------")

	for point in destruction_area.polygon:
	
		# Localize the polygons point.
		var localized_position: Vector2 = (destruction_area.global_position - global_position)

		# Rotate the polygon point.
		var rotated_position: Vector2 = Vector2()
		rotated_position.x = (point.x * cos(dest_area_rotation)) - (point.y * sin(dest_area_rotation))
		rotated_position.y = (point.y * cos(dest_area_rotation)) + (point.x * sin(dest_area_rotation))

		# print("LP:    ", localized_position)
		# print("RP:    ", rotated_position)
		# print("LP+RP: ", localized_position + rotated_position)
		# print("--------------------------")


		# Combine the localized point with the rotation
		# and add them into the new_poly_points array.
		new_poly_points.append(localized_position + rotated_position)
	
	offset_poly.polygon = PackedVector2Array(new_poly_points)

	return offset_poly
