extends Area2D


func clip(poly):
	print(poly.global_position)

	var res = Geometry2D.clip_polygons($Polygon2D.polygon, poly.polygon)
	
	$Polygon2D.polygon = res[0]
	$CollisionPolygon2D.set_deferred("polygon", res[0])

	
