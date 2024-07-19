extends Area2D

@export var speed: float = 1000.0

var movement_vector: Vector2 = Vector2.UP

var curr_speed: float:

	set(value):
		curr_speed = value


func _physics_process(delta):

	global_position += movement_vector.rotated(rotation) * (speed + curr_speed) * delta

func _on_area_entered(area):

	if area.is_in_group("asteroids"):
		area.clip($Area2D/ExplosionArea)
