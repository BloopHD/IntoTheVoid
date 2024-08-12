extends RigidBody2D

var new_asteroid_scene: PackedScene = load("res://scenes/asteroid/asteroid.tscn")

var minimum_size: float = 1250.0

var area: float

func _ready() -> void:

	calculate_polygon_properties()
	check_size_requirment()
		

func _physics_process(delta):

	#rotate(0.04 * delta)
	

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
	
	
	# var test: Polygon2D = localize(destruction_area, transformed_projectile_position)

	var explosion: PackedVector2Array = create_explosion_area(transformed_projectile_position, 10, 35, destruction_area.global_rotation)

	# destruction_area.position = transform.basis_xform_inv(destruction_area.global_position - global_position)
	var new_asteroids: Array[PackedVector2Array] = Geometry2D.clip_polygons($Polygon2D.polygon, explosion)

	

	# print($Polygon2D.polygon)
	# print(new_asteroids)
	# print(new_asteroids.size())
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

			splinter($Polygon2D.polygon, transformed_projectile_position)

			$CollisionPolygon2D.set_deferred("polygon", new_asteroids[i])


func create_explosion_area(destination, sides, radious = 1, _rotation = 0) -> PackedVector2Array:
	
	var explosion_points: Array[Vector2] = []
	
	var segment = PI * 2 / sides

	for i in sides:

		var noise = randf_range(-0.10, 0.10) * segment

		var new_point: Vector2 = Vector2(
			sin((segment + noise) * i + _rotation) * radious,
			cos((segment + noise) * i + _rotation) * radious,
		)

		# var not_too_close: bool = true

		# if explosion_points.size() > 0:
		# 	for point in explosion_points:
		# 		if point - new_point < Vector2(0.05, 0.05) * segment:
		# 			not_too_close = false
		# 	if not_too_close:	
		# 		explosion_points.append(new_point + destination)
		# else:
		# 	explosion_points.append(new_point + destination)
		
		explosion_points.append(new_point + destination)
		
	
	return explosion_points
	

func splinter(poly, hit_location):
	
	var splinter_start

	for i in poly:
		pass

	pass



func localize(destruction_area, new_transform: Vector2 ) -> Polygon2D:

	var offset_poly = Polygon2D.new()
	offset_poly.global_position = Vector2.ZERO

	var new_poly_points: Array[Vector2] = []

	var dest_area_rotation: float = destruction_area.rotation

	var localized_position: Vector2 = (destruction_area.position + new_transform)

	for point in destruction_area.polygon:
	
		# Localize the polygons point.
		# var localized_position: Vector2 = (destruction_area.global_position + new_transform)

		# var rotated_position: Vector2 = Vector2()
		# rotated_position.x = (point.x * cos(dest_area_rotation)) - (point.y * sin(dest_area_rotation))
		# rotated_position.y = (point.y * cos(dest_area_rotation)) + (point.x * sin(dest_area_rotation))

		new_poly_points.append(localized_position + point)
	
	offset_poly.polygon = PackedVector2Array(new_poly_points)

	offset_poly.rotation = dest_area_rotation


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
