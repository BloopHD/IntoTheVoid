extends Area2D

@onready var destruction_area: CollisionPolygon2D = $Area2D/ExplosionArea

@export var speed: float = 1000.0

var movement_vector: Vector2 = Vector2.UP

var curr_speed: float:
	set(value):
		curr_speed = value


func _physics_process(delta):

	global_position += movement_vector.rotated(rotation) * (speed + curr_speed) * delta


func _on_area_entered(area):

	if area.is_in_group("asteroids"):
		destruction_area.rotation = rotation
		area.clip(destruction_area)
		queue_free()
