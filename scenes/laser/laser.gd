extends RigidBody2D

@onready var destruction_area: CollisionPolygon2D = $Area2D/ExplosionArea

@export var speed: float = 1000.0

var movement_vector: Vector2 = Vector2.UP

var curr_speed: float:
	set(value):
		curr_speed = value


func _physics_process(delta):

	global_position += movement_vector.rotated(rotation) * (speed + curr_speed) * delta


func _on_body_entered(body:Node2D):

	if body.is_in_group("asteroids"):
		body.clip(destruction_area)
		queue_free()
