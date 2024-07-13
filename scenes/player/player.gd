extends CharacterBody2D

signal laser(pos, dir, curr_speed)

@export var max_speed: int = 500
@export var accel: int = 500
@export var friction: int = 100
@export var rotation_speed: int = 250

const NINETY_DEGREES: int = 90

var can_shoot: bool = true

var curr_speed: float:
	get:
		return velocity.length()

func _process(_delta):
	check_input()

func _physics_process(delta):
	player_movement(delta)

func check_input():
	if Input.is_action_pressed("primary action") and can_shoot:
		var laser_marker = $LaserMarkers/LaserMarker
		var pos: Vector2 = laser_marker.global_position
		var dir: Vector2 = (get_global_mouse_position() - position).normalized()
		can_shoot = false
		$LaserTimer.start()
		laser.emit(pos, dir, curr_speed)
	elif Input.is_action_pressed("secondary action"):
		print("boom")

func get_thrust() -> float:
	var thrust: float = Input.get_action_strength("up")
	return thrust

func player_movement(delta) -> void:
	var look_dir: Vector2 = player_rotation()
	var thrust: float = get_thrust()
	
	if thrust <= 0.001:
		if velocity.length() > (friction * delta):
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
	
	var look_dir = (get_global_mouse_position() - position).normalized()
	print("look dir, ", look_dir)
	#rotation_degrees = rad_to_deg(look_dir.angle()) + NINETY_DEGREES
	return look_dir

func _on_timer_timeout():
	can_shoot = true
