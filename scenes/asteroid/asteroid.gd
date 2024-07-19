class_name Asteroid extends Area2D

signal exploded(pos, size, points)

var movement_vector = Vector2(0, -1)

enum AsteroidSize{LARGE, MEDIUM, SMALL}
@export var size = AsteroidSize.LARGE

var speed = 5

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

var points: int:
	get:
		match size:
			AsteroidSize.LARGE:
				return 100
			AsteroidSize.MEDIUM:
				return 50
			AsteroidSize.SMALL:
				return 25
			_:
				return 0

func _ready():
	rotation = randf_range(0, 2 * PI)
	
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(50, 100)
			sprite.texture = preload("res://sprites/SimpleAsteroidLarge.png")
			cshape.set_deferred("shape", preload("res://scenes/asteroid/asteroid_cshape_large.tres"))
		AsteroidSize.MEDIUM:
			speed = randf_range(100, 150)
			sprite.texture = preload("res://sprites/SimpleAsteroidMed.png")
			cshape.set_deferred("shape", preload("res://scenes/asteroid/asteroid_cshape_med.tres"))
		AsteroidSize.SMALL:
			speed = randf_range(100, 200)
			sprite.texture = preload("res://sprites/SimpleAsteroidSmall.png")
			cshape.set_deferred("shape", preload("res://scenes/asteroid/asteroid_cshape_small.tres"))

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	var screen_size = get_viewport_rect().size
	var shape_radius = cshape.shape.radius
	
	if global_position.y + shape_radius < 0:
		global_position.y = screen_size.y + shape_radius
	elif global_position.y - shape_radius > screen_size.y:
		global_position.y = -shape_radius
	
	if global_position.x + shape_radius < 0:
		global_position.x = screen_size.x + shape_radius
	elif global_position.x - shape_radius > screen_size.x:
		global_position.x = -shape_radius
	

func explode():
	emit_signal("exploded", global_position, size, points)
	queue_free()


func _on_body_entered(body):
	if body is Player:
		var player = body
		player.die()
