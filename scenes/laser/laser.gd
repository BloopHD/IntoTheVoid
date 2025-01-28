extends Area2D

@onready var destruction_area: CollisionPolygon2D = $Area2D/ExplosionArea
@onready var kill_timer: Timer = $KillTimer

@export var damage: float = 5.0

@export var speed: float = 1500.0
@export var force: float = 5.0

var movement_vector: Vector2 = Vector2.RIGHT

var force_direction: Vector2 = Vector2()

var starting_speed: float:
	set(value):
		starting_speed = value


func _ready() -> void:
	kill_timer.start()


func _physics_process(delta: float) -> void:
	force_direction = movement_vector.rotated(rotation)
	global_position += force_direction * (speed + starting_speed) * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("asteroids"):
		#destruction_area.rotation = global_rotation
		body.clip($CollisionShape2D, force_direction)
		# print(global_position)
		#body.apply_impulse(force_direction * force)

		queue_free()
		
	if body.is_in_group("enemy") || body.is_in_group("player"):
		body.handle_hit(damage)
		queue_free()
		

func _on_area_entered(area:Area2D) -> void:
	if area.is_in_group("enemy shield") || area.is_in_group("player shield"):
		area.damage_shield(damage)
		queue_free()

func _on_kill_timer_timeout() -> void:
	queue_free()
