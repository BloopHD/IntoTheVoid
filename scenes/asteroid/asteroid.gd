extends RigidBody2D

var new_asteroid_scene: PackedScene = load("res://scenes/asteroid/asteroid.tscn")

var minimum_size: float = 1250.0

var area: float

func _ready() -> void:

	calculate_polygon_properties()
	check_size_requirment()
		

func _physics_process(delta):

	#rotate(0.02 * delta)

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


func clip(hit_location, force_direction) -> void:
	
	var transformed_projectile_position = transform.basis_xform_inv(hit_location.global_position - global_position)
	
	# var test: Polygon2D = localize(hit_location, transformed_projectile_position)

	var explosion: PackedVector2Array = create_explosion_area(transformed_projectile_position, 8, 35, hit_location.global_rotation)

	# hit_location.position = transform.basis_xform_inv(hit_location.global_position - global_position)
	var new_asteroids: Array[PackedVector2Array] = Geometry2D.clip_polygons($Polygon2D.polygon, explosion)

	var splinter_array
	
	var splinter_line: Line2D = Line2D.new()
	# splinter_line.position = transformed_projectile_position

	if (randf() > 0.0):
		splinter_line.add_point(transformed_projectile_position)

		var rand = randf()

		var direction = randf_range(0.85, 1.15) * hit_location.global_rotation

		splinter_line.add_point((transformed_projectile_position - global_position) * hit_location.global_rotation * 100)

	get_parent().add_child(splinter_line)


		
		

	# for i in new_asteroids.size():
	# 	for j in new_asteroids[i]:
	# 		for k in explosion:
	# 			if j == k:
	# 				print("match: ", j, " ", k)

					

	# 				if (randf() > 0):
	# 					splinter_array = splinter(j, new_asteroids[i][randi_range(0, new_asteroids[i].size() - 1)])
	# 					var new_new_asteroids: Array[PackedVector2Array] = Geometry2D.clip_polygons(new_asteroids[i], splinter_array)
						
	# 					new_asteroids.remove_at(i)

						
	# 					new_asteroids.append(new_new_asteroids)
	

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


func create_explosion_area(destination, sides, radious = 1, _rotation = 0) -> PackedVector2Array:
	
	var explosion_points: Array[Vector2] = []
	
	var segment = PI * 2 / sides

	for i in sides:

		var noise = randf_range(-0.15, 0.15) * segment

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
	

func splinter(splinter_start: Vector2, splinter_finish: Vector2):

	var splinter_poly: Polygon2D = Polygon2D.new()
	
	var length = splinter_start - splinter_finish

	var point_1 = length * 0.33
	var point_2 = length * 0.66

	var splinter_array: PackedVector2Array = [splinter_start, point_1, splinter_finish, point_2]
	
	return splinter_array





func localize(hit_location, new_transform: Vector2 ) -> Polygon2D:

	var offset_poly = Polygon2D.new()
	offset_poly.global_position = Vector2.ZERO

	var new_poly_points: Array[Vector2] = []

	var dest_area_rotation: float = hit_location.rotation

	var localized_position: Vector2 = (hit_location.position + new_transform)

	for point in hit_location.polygon:
	
		# Localize the polygons point.
		# var localized_position: Vector2 = (hit_location.global_position + new_transform)

		# var rotated_position: Vector2 = Vector2()
		# rotated_position.x = (point.x * cos(dest_area_rotation)) - (point.y * sin(dest_area_rotation))
		# rotated_position.y = (point.y * cos(dest_area_rotation)) + (point.x * sin(dest_area_rotation))

		new_poly_points.append(localized_position + point)
	
	offset_poly.polygon = PackedVector2Array(new_poly_points)

	offset_poly.rotation = dest_area_rotation


	return offset_poly


func localize_and_rotate(hit_location, new_transform: Vector2) -> Polygon2D:
	
	var offset_poly = Polygon2D.new()
	offset_poly.global_position = Vector2.ZERO

	var dest_area_rotation: float = hit_location.global_rotation
	var new_poly_points: Array[Vector2] = []

	# print("DA.GP: ", hit_location.global_position)
	# print("GP   :  ", global_position)
	# print("GP   :  ", hit_location.global_position - global_position)
	# print("--------------------------")

	for point in hit_location.polygon:
	
		# Localize the polygons point.
		var localized_position: Vector2 = (hit_location.global_position - global_position)

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
