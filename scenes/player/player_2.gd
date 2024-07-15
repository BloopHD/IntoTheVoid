class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died


const NINETY_DEGREES: int = 90
const NINETY_DEGREES_RAD: float = 1.5708

@export var acceleration: float = 15.0
@export var slow_down: float = 5.0
@export var max_speed: float = 1000.0
@export var rotation_speed: float = 250.0

@onready var muzzle: Marker2D = $Muzzle
@onready var sprite: Sprite2D = $Sprite2D
@onready var cshape: CollisionShape2D = $CollisionShape2D

var laser_scene: PackedScene = preload("res://scenes/laser/laser_2.tscn")

var shoot_cd: bool = false
var rate_of_fire: float = 0.15

var alive: bool = true

func _process(_delta):
	if !alive:
		return
	
	if Input.is_action_pressed("fire_laser"):
		if !shoot_cd:
			shoot_laser()
			shoot_cd = true
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cd = false
			

func _physics_process(_delta):
	if !alive:
		return
		
	var input_vector: Vector2 = Vector2(0, Input. get_axis("up", "down"))
	
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	var look_dir: Vector2 = (get_global_mouse_position() - position).normalized()
	var curr_look_dir: Vector2 = global_transform.y.normalized()

	var angle = look_dir.angle() + NINETY_DEGREES_RAD
	var gr = global_rotation

	rotation_degrees = rad_to_deg(lerp_angle(gr, angle, .1))
	print("rd, ", rotation_degrees)
	print("gr, ", gr)
	print(" ")
	# if Input.is_action_pressed("right"):
	# 	rotate(deg_to_rad(rotation_speed * delta))
	# elif Input.is_action_pressed("left"):
	# 	rotate(deg_to_rad(-rotation_speed * delta))
		
	
	if input_vector.y <= 0.001:
		velocity = velocity.move_toward(Vector2.ZERO, slow_down)
	
	move_and_slide()
	
	var screen_size = get_viewport_rect().size
	
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
		
		
func shoot_laser():
	var laser: Area2D = laser_scene.instantiate()
	laser.global_position = muzzle.global_position
	laser.rotation = rotation
	emit_signal("laser_shot", laser)

func die():
	if alive == true:
		alive = false
		emit_signal("died")
		sprite.visible = false
		cshape.set_deferred("disabled", true)

func respawn(pos):
	if alive == false:
		alive = true
		global_position = pos
		velocity = Vector2.ZERO
		sprite.visible = true
		cshape.set_deferred("disabled", false)
