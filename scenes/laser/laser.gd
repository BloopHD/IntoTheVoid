extends Area2D

@onready var destruction_area: CollisionPolygon2D = $Area2D/ExplosionArea

@export var speed: float = 1000.0
@export var force: float = 5.0

var movement_vector: Vector2 = Vector2.UP

var force_direction: Vector2 = Vector2()

var curr_speed: float:
	set(value):
		curr_speed = value


func _physics_process(delta) -> void:

	force_direction = movement_vector.rotated(rotation)
	global_position += force_direction * (speed + curr_speed) * delta


func _on_body_entered(body:Node2D) -> void:
	
	if body.is_in_group("asteroids"):
		#destruction_area.rotation = global_rotation
		body.clip($CollisionShape2D, force_direction)
		# print(global_position)
		#body.apply_impulse(force_direction * force)

		queue_free()
		
	if body.is_in_group("enemy"):
		print("Enemy Hit")