extends CharacterBody2D

signal laser_shot(laser)

@export var max_speed: int = 500
@export var accel: int = 500
@export var friction: int = 100
@export var rotation_speed: int = 250

@onready var muzzle: Marker2D = $LaserMarkers/LaserMarker

var laser_scene: PackedScene = preload("res://scenes/laser/laser.tscn")

const NINETY_DEGREES: int = 90
const NINETY_DEGREES_RAD: float = 1.5708

var can_shoot: bool = true

var curr_speed: float:
	get:
		return velocity.length()

func _process(_delta):
	check_input()

func _physics_process(delta):
	player_movement(delta)

func check_input():
	if (Input.is_action_pressed("primary action") or Input.is_action_pressed("fire_laser")) and can_shoot:
		shoot_laser()
		can_shoot = false
		$LaserTimer.start()
	elif Input.is_action_pressed("secondary action"):
		print("boom")

func get_thrust() -> float:
	var thrust: float = Input.get_action_strength("up")
	return thrust

func player_movement(delta) -> void:
	var look_dir: Vector2 = player_rotation()
	var thrust: float = get_thrust()
	curr_speed = velocity.length()
	
	if thrust <= 0.001:
		if curr_speed > (friction * delta):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		var thrust_power: float = (thrust * accel * delta)
		var thrust_velocity: Vector2 = look_dir * thrust_power
		velocity += thrust_velocity
		velocity = velocity.limit_length(max_speed)
	
	move_and_slide()

func player_rotation() -> Vector2:

	var look_dir: Vector2

	# TODO: Allow turning with A & D. And Controller.
	# var left: float = Input.get_action_strength("left") 
	# var right: float = Input.get_action_strength("right")

	# Keyboard turning controls take priority, so always turn
	# on keyboard input.
	# if (left != 0 || right != 0):
		# TODO: set look_dir to the correct direction.
		# pass 
	
	# Then, if the mouse has not moved stay the direction
	# player is currently facing. Or if the mouse has moved,
	# go ahead and move toward mouse.
	# elif !Input.get_last_mouse_velocity():
	# 	look_dir = (get_global_mouse_position() - position).normalized()
	# 	print(look_dir)
	
	look_dir = (get_global_mouse_position() - position).normalized()
	var angle = look_dir.angle() + NINETY_DEGREES_RAD
	rotation_degrees = rad_to_deg(lerp_angle(global_rotation, angle, .1))
		
	return look_dir

func _on_timer_timeout():
	can_shoot = true

func shoot_laser():
	var laser: RigidBody2D = laser_scene.instantiate()
	laser.global_position = muzzle.global_position
	laser.rotation = rotation
	laser.curr_speed = curr_speed
	emit_signal("laser_shot", laser)
