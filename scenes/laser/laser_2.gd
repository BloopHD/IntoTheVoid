extends Area2D

@export var speed: float = 500.0

var movement_vector: Vector2 = Vector2.UP

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_area_entered(area):
	print(area)
	if area is Asteroid:
		var asteroid = area
		asteroid.explode()
		queue_free()
