extends Area2D

@export var speed: float = 1000.0
@export var force: float = 5.0
@export var damage: int = 5

var movement_vector: Vector2 = Vector2.UP

var force_direction: Vector2 = Vector2()

var curr_speed: float:
	set(value):
		curr_speed = value


func _physics_process(delta) -> void:

	force_direction = movement_vector.rotated(rotation)
	global_position += force_direction * (speed + curr_speed) * delta

func _on_body_entered(body:Node2D) -> void:
	
	if body.is_in_group("player"):
		body.handle_hit(damage)
		queue_free()
		

func _on_area_entered(area:Area2D) -> void:
	
	if area.is_in_group("player shield"):
		area.damage_shield(damage)
		queue_free()
