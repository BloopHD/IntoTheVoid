extends Area2D

@export var speed: int = 1000

var direction: Vector2 = Vector2.UP

var curr_speed: float:
	set(value):
		curr_speed = value
	

func _physics_process(delta):
	position += direction * (speed + curr_speed) * delta
 
